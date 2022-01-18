/*
**  exec.prg -- Execution module
**
** (c) FiveTech Software SL, 2019-2020
** Developed by Antonio Linares alinares@fivetechsoft.com
** MIT license https://github.com/FiveTechSoft/mod_harbour/blob/master/LICENSE
*/
#include "hbclass.ch"
#include "hbhrb.ch"

#include "mh_apache.ch"

THREAD STATIC hPP

FUNCTION MH_AddPPRules()

   LOCAL cOs := OS()
   LOCAL n, aPair, cExt 

   IF hPP == nil
      hPP = __pp_Init()

      DO CASE
      CASE "Windows" $ cOs  ; __pp_Path( hPP, "c:\harbour\include" )
      CASE "Linux" $ cOs   ; __pp_Path( hPP, "~/harbour/include" )
      ENDCASE

      IF ! Empty( hb_GetEnv( "HB_INCLUDE" ) )
         __pp_Path( hPP, hb_GetEnv( "HB_INCLUDE" ) )
      ENDIF
   ENDIF

   __pp_AddRule( hPP, "#xcommand ? [<explist,...>] => ap_Echo( '<br>' [,<explist>] )" )
   __pp_AddRule( hPP, "#xcommand ?? [<explist,...>] => ap_Echo( [<explist>] )" )
   __pp_AddRule( hPP, "#define CRLF hb_OsNewLine()" )
   __pp_AddRule( hPP, "#xcommand TEXT <into:TO,INTO> <v> => #pragma __cstream|<v>:=%s" )
   __pp_AddRule( hPP, "#xcommand TEXT <into:TO,INTO> <v> ADDITIVE => #pragma __cstream|<v>+=%s" )
   __pp_AddRule( hPP, "#xcommand TEMPLATE [ USING <x> ] [ PARAMS [<v1>] [,<vn>] ] => " + ;
      '#pragma __cstream | ap_Echo( mh_InlinePrg( %s, [@<x>] [,<(v1)>][+","+<(vn)>] [, @<v1>][, @<vn>] ) )' )
   __pp_AddRule( hPP, "#xcommand BLOCKS [ PARAMS [<v1>] [,<vn>] ] => " + ;
      '#pragma __cstream | ap_Echo( mh_ReplaceBlocks( %s, "{{", "}}" [,<(v1)>][+","+<(vn)>] [, @<v1>][, @<vn>] ) )' )
   __pp_AddRule( hPP, "#xcommand BLOCKS TO <b> [ PARAMS [<v1>] [,<vn>] ] => " + ;
      '#pragma __cstream | <b>+=mh_ReplaceBlocks( %s, "{{", "}}" [,<(v1)>][+","+<(vn)>] [, @<v1>][, @<vn>] )' )
   __pp_AddRule( hPP, "#command ENDTEMPLATE => #pragma __endtext" )
   __pp_AddRule( hPP, "#xcommand TRY  => BEGIN SEQUENCE WITH {| oErr | Break( oErr ) }" )
   __pp_AddRule( hPP, "#xcommand CATCH [<!oErr!>] => RECOVER [USING <oErr>] <-oErr->" )
   __pp_AddRule( hPP, "#xcommand FINALLY => ALWAYS" )
   __pp_AddRule( hPP, "#xcommand DEFAULT <v1> TO <x1> [, <vn> TO <xn> ] => ;" + ;
      "IF <v1> == NIL ; <v1> := <x1> ; END [; IF <vn> == NIL ; <vn> := <xn> ; END ]" )
	

	//	InitProcess .ch files
	
	for n := 1 to len(MH_AppModules())
	
		aPair 	:= HB_HPairAt( MH_AppModules(), n )		
		cExt 	:= lower( hb_FNameExt( aPair[1] ) )

		if cExt == '.ch' 	
			__pp_AddRule( hPP, aPair[2] )			
		endif 
		
	next 

RETURN hPP


FUNCTION MH_ExecuteHrb( oHrb, ... )

   LOCAL uRet, pSym

   ErrorBlock( {| oError | ap_Echo( mh_ErrorSys( oError ) ), Break( oError ) } )  

	WHILE !hb_mutexLock( mh_Mutex() )
	ENDDO

	pSym := hb_hrbLoad( HB_HRB_BIND_OVERLOAD, oHrb )
	  
	hb_mutexUnlock( mh_Mutex() )	
   
   uRet := hb_hrbDo( pSym, ... )

RETURN uRet

// ----------------------------------------------------------------//

FUNCTION MH_Execute( cCode, ... )

	local oHrb := MH_Compile( cCode, ... )	
	local pSym 

   IF ! Empty( oHrb )
   
	  WHILE !hb_mutexLock( mh_Mutex() )
	  ENDDO	  

	  pSym := hb_hrbLoad( HB_HRB_BIND_OVERLOAD, oHrb )
	  
	  hb_mutexUnlock( mh_Mutex() )

      uRet := hb_hrbDo( pSym, ... )

   ENDIF	

retu uRet 

FUNCTION MH_Compile( cCode, ... )

   LOCAL oHrb, pCode, uRet
   LOCAL cOs   		:= OS()
   LOCAL cHBHeader  := ''
   LOCAL cCodePP	:= ''

   DO CASE
   CASE "Windows" $ cOs  ; cHBHeader := "c:\harbour\include"
   CASE "Linux" $ cOs   ; cHBHeader := "~/harbour/include"
   ENDCASE

   ErrorBlock( {| oError | mh_ErrorSys( oError, @cCode, @cCodePP ), Break( oError ) } )

   mh_AddPPRules()   
   
	mh_ReplaceBlocks( @cCode, "{%", "%}" )
	
	cCodePP := __pp_Process( hPP, cCode )

	oHrb = HB_CompileFromBuf( cCodePP, .T., "-n", "-q2", "-I" + cHBheader, ;
			"-I" + hb_GetEnv( "HB_INCLUDE" ), hb_GetEnv( "HB_USER_PRGFLAGS" ) )	

RETURN oHrb


// ----------------------------------------------------------------//

PROCEDURE DoBreak( oError )

   // ? GetErrorInfo( oError )

   BREAK


// ----------------------------------------------------------------//

FUNCTION MH_InlinePRG( cText, oTemplate, cParams, ... )

   LOCAL nStart, nEnd, cCode, cResult

   IF PCount() > 1
      oTemplate = mh_Template()
      IF PCount() > 2
         oTemplate:cParams = cParams
      ENDIF
   ENDIF

   WHILE ( nStart := At( "<?prg", cText ) ) != 0
      nEnd  = At( "?>", SubStr( cText, nStart + 5 ) )
      cCode = SubStr( cText, nStart + 5, nEnd - 1 )
      IF oTemplate != nil
         AAdd( oTemplate:aSections, cCode )
      ENDIF
      cText = SubStr( cText, 1, nStart - 1 ) + ( cResult := mh_ExecInline( cCode, cParams, ... ) ) + ;
         SubStr( cText, nStart + nEnd + 6 )
      IF oTemplate != nil
         AAdd( oTemplate:aResults, cResult )
      ENDIF
   END

   IF oTemplate != nil
      oTemplate:cResult = cText
   ENDIF

RETURN cText

// ----------------------------------------------------------------//

FUNCTION MH_ExecInline( cCode, cParams, ... )

   IF cParams == nil
      cParams = ""
   ENDIF

RETURN MH_Execute( "function __Inline( " + cParams + " )" + hb_osNewLine() + cCode, ... )

// ----------------------------------------------------------------//

FUNCTION MH_ReplaceBlocks( cCode, cStartBlock, cEndBlock, cParams, ... )

	LOCAL nStart, nEnd, cBlock
	LOCAL lReplaced := .F.
   
	hb_default( @cStartBlock, "{{" )
	hb_default( @cEndBlock, "}}" )
	hb_default( @cParams, "" )   

	mh_stackblock( 'type', 'block' )      
	mh_stackblock( 'code', cCode )      

	WHILE ( nStart := At( cStartBlock, cCode ) ) != 0 .AND. ;
         ( nEnd := At( cEndBlock, cCode ) ) != 0
		 
		cBlock = SubStr( cCode, nStart + Len( cStartBlock ), nEnd - nStart - Len( cEndBlock ) )
	  
		mh_stackblock( 'error', cStartBlock + cBlock + cEndBlock)

		cCode = SubStr( cCode, 1, nStart - 1 ) + ;
        mh_ValToChar( Eval( &( "{ |" + cParams + "| " + cBlock + " }" ), ... ) ) + ;
        SubStr( cCode, nEnd + Len( cEndBlock ) )		 

		lReplaced = .T.
	END         
   
	mh_stackblock()      

RETURN If( hb_PIsByRef( 1 ), lReplaced, cCode )

// ----------------------------------------------------------------//

CLASS MH_Template

   DATA aSections INIT {}
   DATA aResults  INIT {}
   DATA cParams
   DATA cResult

ENDCLASS

// ----------------------------------------------------------------//


function MH_IsFun( u )

	local nLen := __DynsCount()
	local h 	:= {}
	
   _d( 'ISFUN() => ' + u ) 

    for n = nLen to 1 step -1
   
        if __DynsIsFun( n )
			Aadd( h, __DynsGetName( n ) )						
        endif

    next	  
  
retu Ascan( h, u ) > 0 


// ----------------------------------------------------------------//
