/*
** hw_apache.prg -- Apache harbour module V2
** (c) DHF, 2020-2021
** MIT license
*/


#ifdef __PLATFORM__WINDOWS
#include "externs.hbx"
#endif

#include "hbthread.ch"
#include "hbclass.ch"
#include "hbhrb.ch"
#include "hw_apache.ch"

#define CRLF hb_OsNewLine()

THREAD STATIC request_rec
THREAD STATIC _cBuffer_Out 	:= ''
THREAD STATIC _hHrbs 		
THREAD STATIC _aFiles 		
THREAD STATIC _bError 		


FUNCTION Main()


  
RETURN NIL

//	------------------------------------------------------------------	//

FUNCTION HW_Thread( r )

   LOCAL cFileName
   LOCAL pThreadWait
   LOCAL oHrb
   
   //	Init thread statics vars
   
		request_rec 	:= r			//	Request from Apache
		_cBuffer_Out 	:= ''			//	Buffer for text out
		_hHrbs 			:= {=>}			//	Internal hash of loaded hrbs
		_aFiles			:= {}			//	Internal array of loaded name files		
   
   //	------------------------


   ErrorBlock( {| oError | GetErrorInfo( oError ), Break( oError ) } )

   pThreadWait := hb_threadStart( @HW_RequestMaxTime(), hb_threadSelf(), 15 ) // 15 Sec max

   cFileName = AP_FileName()  // HW_FileName()

   IF File( cFileName )

      IF Lower( Right( cFileName, 4 ) ) == ".hrb"

         hb_hrbDo( hb_hrbLoad( 2, cFileName ), AP_Args() )  // HW_Args()

      ELSE

         hb_SetEnv( "PRGPATH", ;
            SubStr( cFileName, 1, RAt( "/", cFileName ) + RAt( "\", cFileName ) - 1 ) )
         cCode := MemoRead( cFileName )

        Execute( cCode, AP_Args() ) // HW_Execute( cCode )

      ENDIF

   ELSE

      HW_EXITSTATUS( 404 )

   ENDIF

 
   while( hb_threadQuitRequest( pThreadWait ) )
      hb_idleSleep( 0.01 )
   ENDDO   
   

	//	Output of buffered text
   
		AP_RPuts_Out( _cBuffer_Out )      
   
    //	Unload hrbs loaded. 
   
		MH_LoadHrb_Clear()

RETURN

// ----------------------------------------------------------------//

FUNCTION GetRequestRec()

RETURN request_rec

// ----------------------------------------------------------------//

FUNCTION HW_RequestMaxTime( pThread, nTime )

   hb_idleSleep( nTime )      

   while( hb_threadQuitRequest( pThread ) )
      hb_idleSleep( 0.01 )
   ENDDO


RETURN


// ----------------------------------------------------------------//

FUNCTION AP_RPUTS( ... )
  
   LOCAL aParams := hb_AParams()
   LOCAL n 		 := Len( aParams )
   
   IF n == 0
	  RETURN NIL
   ENDIF

   FOR i = 1 TO n - 1 
      _cBuffer_Out += valtochar( aParams[ i ] ) + ' '
   NEXT

   _cBuffer_Out += valtochar( aParams[ n ] )   

RETURN

// ----------------------------------------------------------------//
/*
#define HB_HRB_BIND_DEFAULT      0x0    do not overwrite any functions, ignore
                                          public HRB functions if functions with
                                          the same names already exist in HVM 

#define HB_HRB_BIND_LOCAL        0x1    do not overwrite any functions
                                          but keep local references, so
                                          if module has public function FOO and
                                          this function exists also in HVM
                                          then the function in HRB is converted
                                          to STATIC one 

#define HB_HRB_BIND_OVERLOAD     0x2    overload all existing public functions 

#define HB_HRB_BIND_FORCELOCAL   0x3    convert all public functions to STATIC ones 

#define HB_HRB_BIND_MODEMASK     0x3    HB_HRB_BIND_* mode mask 

#define HB_HRB_BIND_LAZY         0x4    lazy binding with external public
                                          functions allows to load .hrb files
                                          with unresolved or cross function
                                          references 

*/

/* 	Dentro el paradigma del server multihilo, el objetivo es cargar los hrbs dentro
	del propio hilo, y que al final del proceso de descarguen de la tabla de simbolos.
	Hemos de tener en cuenta que puede haber mas de 1 hilo que use el mismo hrb, por 
	lo que si descarga un hrb un hilo que lo haya ejecutado, no afecte a otro que lo
	tenga en uso.
*/

FUNCTION MH_LoadHrb( cHrbFile_or_oHRB )

    local lResult 	:= .F.   
    local cType 	:= ValType( cHrbFile_or_oHRB )   

	do case
	
		case cType == 'C'
		
			if File( hb_GetEnv( "PRGPATH" ) + "/" + cHrbFile_or_oHRB )
		
				if ! HB_HHasKey( _hHrbs, cHrbFile_or_oHRB )
					_hHrbs[ cHrbFile_or_oHRB ] := hb_HrbLoad( HB_HRB_BIND_DEFAULT, hb_GetEnv( "PRGPATH" ) + "/" + cHrbFile_or_oHRB ) 				
					
_d( HB_HRBGETFUNLIST( _hHrbs[ cHrbFile_or_oHRB ] ) )					
					
				endif 				
		
			endif
			
		case cType == 'P'

				_hHrbs[ cHrbFile_or_oHRB ] := hb_HrbLoad( HB_HRB_BIND_DEFAULT, hb_GetEnv( "PRGPATH" ) + "/" + cHrbFile_or_oHRB ) 
		
	endcase 
	
retu ''

// ----------------------------------------------------------------//

FUNCTION MH_LoadHrb_Clear()

	local n 

	for n = 1 to len( _hHrbs )
		aPair := HB_HPairAt( _hHrbs, n )		
		hb_hrbUnLoad( aPair[2] )			
	next 

retu nil 

// ----------------------------------------------------------------//

FUNCTION MH_LoadFile( cFile )

	local cPath_File	:= hb_GetEnv( "PRGPATH" ) + '/' + cFile 		

    if Ascan( _aFiles, cFile ) > 0
		retu ''
	endif	

    if File( cPath_File )

		Aadd( _aFiles, cFile )	
		return hb_MemoRead( cPath_File )
		
	else		
		MH_DoError( "MH_LoadFile() file not found: " + cPath_File  )
    endif


retu ''

// ----------------------------------------------------------------//
		 
function MH_ErrorInfo( oError, cCode )

	hb_default( @cCode, "" )

	if valtype( _bError ) == 'B'
	
		_cBuffer_Out := ''	
		Eval( _bError, oError, cCode )		
		AP_RPuts_Out( _cBuffer_Out )
		
	else 	
		GetErrorInfo( oError, @cCode )	
	endif 

retu nil

function MH_ErrorBlock( bBlockError ) 	
	_bError := bBlockError 
retu nil 

//----------------------------------------------------------------//

function MH_DoError( cDescription, cSubsystem ) 

	local oError := ErrorNew()
	
	hb_default( @cSubsystem, "modHarbour.v2" )
	
	oError:Subsystem   := cSubsystem
	oError:Severity    := 2	//	ES_ERROR
	oError:Description := cDescription
	Eval( ErrorBlock(), oError)	

return nil