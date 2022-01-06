/*
**  exec.prg -- Execution module
**
** (c) FiveTech Software SL, 2019-2020
** Developed by Antonio Linares alinares@fivetechsoft.com
** MIT license https://github.com/FiveTechSoft/mod_harbour/blob/master/LICENSE
*/
#include "hbclass.ch"
#include "hbhrb.ch"

THREAD STATIC hPP

FUNCTION AddPPRules()

   IF hPP == nil
      hPP = __pp_Init()
      __pp_Path( hPP, "~/harbour/include" )
      __pp_Path( hPP, "c:\harbour\include" )
      IF ! Empty( hb_GetEnv( "HB_INCLUDE" ) )
         __pp_Path( hPP, hb_GetEnv( "HB_INCLUDE" ) )
      ENDIF
   ENDIF

   __pp_AddRule( hPP, "#xcommand ? [<explist,...>] => AP_RPUTS( '<br>' [,<explist>] )" )
   __pp_AddRule( hPP, "#xcommand ?? [<explist,...>] => AP_RPuts( [<explist>] )" )
   __pp_AddRule( hPP, "#define CRLF hb_OsNewLine()" )
   __pp_AddRule( hPP, "#xcommand TEXT <into:TO,INTO> <v> => #pragma __cstream|<v>:=%s" )
   __pp_AddRule( hPP, "#xcommand TEXT <into:TO,INTO> <v> ADDITIVE => #pragma __cstream|<v>+=%s" )
   __pp_AddRule( hPP, "#xcommand TEMPLATE [ USING <x> ] [ PARAMS [<v1>] [,<vn>] ] => " + ;
      '#pragma __cstream | AP_RPuts( InlinePrg( %s, [@<x>] [,<(v1)>][+","+<(vn)>] [, @<v1>][, @<vn>] ) )' )
   __pp_AddRule( hPP, "#xcommand BLOCKS [ PARAMS [<v1>] [,<vn>] ] => " + ;
      '#pragma __cstream | AP_RPuts( ReplaceBlocks( %s, "{{", "}}" [,<(v1)>][+","+<(vn)>] [, @<v1>][, @<vn>] ) )' )
   __pp_AddRule( hPP, "#xcommand BLOCKS TO <b> [ PARAMS [<v1>] [,<vn>] ] => " + ;
      '#pragma __cstream | <b>+=ReplaceBlocks( %s, "{{", "}}" [,<(v1)>][+","+<(vn)>] [, @<v1>][, @<vn>] )' )
   __pp_AddRule( hPP, "#command ENDTEMPLATE => #pragma __endtext" )
   __pp_AddRule( hPP, "#xcommand TRY  => BEGIN SEQUENCE WITH {| oErr | Break( oErr ) }" )
   __pp_AddRule( hPP, "#xcommand CATCH [<!oErr!>] => RECOVER [USING <oErr>] <-oErr->" )
   __pp_AddRule( hPP, "#xcommand FINALLY => ALWAYS" )
   __pp_AddRule( hPP, "#xcommand DEFAULT <v1> TO <x1> [, <vn> TO <xn> ] => ;" + ;
      "IF <v1> == NIL ; <v1> := <x1> ; END [; IF <vn> == NIL ; <vn> := <xn> ; END ]" )

RETURN NIL


FUNCTION ExecuteHrb( oHrb, cArgs )

   ErrorBlock( {| oError | AP_RPuts( GetErrorInfo( oError ) ), Break( oError ) } )

RETURN hb_hrbDo( oHrb, cArgs )

// ----------------------------------------------------------------//

FUNCTION Execute( cCode, ... )

   LOCAL oHrb, cCodePP, pCode, uRet, lReplaced := .T.
   LOCAL cOs   := OS()
   LOCAL cHBHeader  := ''

   DO CASE
   CASE "Windows" $ OS() ; cHBHeader := "c:\harbour\include"
   CASE "Linux" $ OS()  ; cHBHeader := "~/harbour/include"
   ENDCASE

   ErrorBlock( {| oError | MH_ErrorInfo( oError, @cCode ), Break( oError ) } )

   AddPPRules()

   ReplaceBlocks( @cCode, "{%", "%}" )
   cCodePP := __pp_Process( hPP, cCode )


   oHrb = HB_CompileFromBuf( cCodePP, .T., "-n", "-q2", "-I" + cHBheader, ;
      "-I" + hb_GetEnv( "HB_INCLUDE" ), hb_GetEnv( "HB_USER_PRGFLAGS" ) )

   IF ! Empty( oHrb )
      uRet := hb_hrbDo( hb_hrbLoad( HB_HRB_BIND_OVERLOAD, oHrb ), ... )
   ENDIF

RETURN uRet


// ----------------------------------------------------------------//

PROCEDURE DoBreak( oError )

   ? GetErrorInfo( oError )

   BREAK


// ----------------------------------------------------------------//

FUNCTION InlinePRG( cText, oTemplate, cParams, ... )

   LOCAL nStart, nEnd, cCode, cResult

   IF PCount() > 1
      oTemplate = Template()
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
      cText = SubStr( cText, 1, nStart - 1 ) + ( cResult := ExecInline( cCode, cParams, ... ) ) + ;
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

FUNCTION ExecInline( cCode, cParams, ... )

   IF cParams == nil
      cParams = ""
   ENDIF

RETURN Execute( "function __Inline( " + cParams + " )" + hb_osNewLine() + cCode, ... )

// ----------------------------------------------------------------//

FUNCTION ReplaceBlocks( cCode, cStartBlock, cEndBlock, cParams, ... )

   LOCAL nStart, nEnd, cBlock
   LOCAL lReplaced := .F.

   hb_default( @cStartBlock, "{{" )
   hb_default( @cEndBlock, "}}" )
   hb_default( @cParams, "" )

   WHILE ( nStart := At( cStartBlock, cCode ) ) != 0 .AND. ;
         ( nEnd := At( cEndBlock, cCode ) ) != 0
      cBlock = SubStr( cCode, nStart + Len( cStartBlock ), nEnd - nStart - Len( cEndBlock ) )
      cCode = SubStr( cCode, 1, nStart - 1 ) + ;
         ValToChar( Eval( &( "{ |" + cParams + "| " + cBlock + " }" ), ... ) ) + ;
         SubStr( cCode, nEnd + Len( cEndBlock ) )
      lReplaced = .T.
   END

RETURN If( hb_PIsByRef( 1 ), lReplaced, cCode )

// ----------------------------------------------------------------//

CLASS Template

   DATA aSections INIT {}
   DATA aResults  INIT {}
   DATA cParams
   DATA cResult

ENDCLASS

// ----------------------------------------------------------------//
