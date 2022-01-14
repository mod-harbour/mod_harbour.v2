/*
** mh_apache.prg -- Apache harbour module V2
** (c) DHF, 2020-2021
** MIT license
*/


#ifdef __PLATFORM__WINDOWS
#include "externs.hbx"
#endif

#include "hbthread.ch"
#include "hbclass.ch"
#include "hbhrb.ch"
#include "mh_apache.ch"

#define CRLF hb_OsNewLine()

THREAD STATIC ts_request_rec
THREAD STATIC ts_cBuffer_Out  := ''
THREAD STATIC ts_hHrbs
THREAD STATIC ts_aFiles
THREAD STATIC ts_bError
THREAD STATIC ts_t_hTimer
THREAD STATIC ts_hConfig 

//	SetEnv Var config.	----------------------------------------
//	MH_CACHE 		-	Use PcodeCached
//	MH_TIMEOUT		-	Timeout for thread
//	MH_PATH_LOG 	- 	Default HB_GetEnv( 'PRGPATH' ) + '/log.txt'
//  MH_INITPROCESS 	-	Init modules at begin of app
//	------------------------------------------------------------


FUNCTION Main()

	

RETURN NIL

// ------------------------------------------------------------------ //

FUNCTION MH_Runner( r )

   LOCAL cFileName, cFilePath, pThreadWait, tFilename, cCode, cCodePP, oHrb     
   LOCAL disablecache := .F.
   

   // Init thread statics vars

   ts_request_rec	:= r   		// Request from Apache
   ts_cBuffer_Out	:= ''   	// Buffer for text out
   ts_hHrbs    		:= { => } 	// Internal hash of loaded hrbs
   ts_aFiles   		:= {}   	// Internal array of loaded name files      

   // Init dependent vars of request 
   
   ts_hConfig 		:= { => }
   
   ts_hConfig[ 'cache' ]	:= AP_GetEnv( 'MH_CACHE' )	== '1' .or. lower( AP_GetEnv( 'MH_CACHE' ) ) == 'yes'  
   ts_hConfig[ 'timeout' ]	:= Max( Val( AP_GetEnv( 'MH_TIMEOUT' ) ), 15 )   
   ts_hConfig[ 'modules' ]	:= AP_GetEnv( 'MH_INITPROCESS' ) 
   
   // ------------------------   
   
   ErrorBlock( {| oError | MH_ErrorSys( oError ), Break( oError ) } )

   ts_t_hTimer = hb_idleAdd( {|| MH_RequestMaxTime( hb_threadSelf(), ts_hConfig[ 'timeout' ] ) }  )

   cFileName = ap_FileName()  


   IF File( cFileName )
   
	  cFilePath := SubStr( cFileName, 1, RAt( "/", cFileName ) + RAt( "\", cFileName ) - 1 ) 

	  hb_SetEnv( "PRGPATH", cFilePath )
	  
	   //	InitApp
	   
			mh_InitProcess()
		  
	   // ------------------------	  	  	  	  	  

      IF Lower( Right( cFileName, 4 ) ) == ".hrb"

         hb_hrbDo( hb_hrbLoad( 2, cFileName ), ap_Args() ) 

      ELSE	//	case prg   
	  
		  
		  cCode := MemoRead( cFileName )	  	  

		  IF ts_hConfig[ 'cache' ] 	

			   hb_FGetDateTime( cFilename, @tFilename )			   

			   IF ( iif( hb_HHasKey( MH_PcodeCached(), cFilename ), tFilename > MH_PcodeCached()[ cFilename ][ 2 ], .T. ) )			   
			   
				  oHrb := mh_Compile( cCode )

				  IF ! Empty( oHrb )

					 WHILE !hb_mutexLock( MH_Mutex() )
					 ENDDO

					 MH_PcodeCached()[ cFilename ] = { oHrb, tFilename }
					 hb_mutexUnlock( MH_Mutex() )

				  ENDIF
				  
			   ELSE

				  oHrb = MH_PcodeCached()[ cFilename ][ 1 ]

			   ENDIF

			   IF ! Empty( oHrb )

				  uRet := hb_hrbDo( hb_hrbLoad( HB_HRB_BIND_OVERLOAD, oHrb ), ap_Args()  )

			   ENDIF		   


		  ELSE   

			 MH_Execute( cCode, ap_Args() ) 

		  ENDIF
		  
	  ENDIF
	  
   ELSE

      mh_ExitStatus( 404 )

   ENDIF

	// Output of buffered text

   ap_RPuts( ts_cBuffer_Out )

   // Unload hrbs loaded.

   mh_LoadHrb_Clear()

RETURN 1

// ----------------------------------------------------------------//

FUNCTION GetRequestRec()

RETURN ts_request_rec

// ----------------------------------------------------------------//

FUNCTION MH_RequestMaxTime( pThread, nTime )

   sec := Seconds()

   DO WHILE ( Seconds() - sec < nTime )
      hb_idleSleep( 0.01 )
   ENDDO

   mh_ExitStatus( 408 )

   while( hb_threadQuitRequest( pThread ) )
      hb_idleSleep( 0.01 )
   ENDDO

RETURN 


// ----------------------------------------------------------------//

FUNCTION AP_ECHO( ... )

   LOCAL aParams := hb_AParams()
   LOCAL n    := Len( aParams )

   IF n == 0
      RETURN NIL
   ENDIF

   FOR i = 1 TO n - 1
      ts_cBuffer_Out += mh_valtochar( aParams[ i ] ) + ' '
   NEXT

   ts_cBuffer_Out += mh_valtochar( aParams[ n ] )

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

/*  Dentro el paradigma del server multihilo, el objetivo es cargar los hrbs dentro
 del propio hilo, y que al final del proceso de descarguen de la tabla de simbolos.
 Hemos de tener en cuenta que puede haber mas de 1 hilo que use el mismo hrb, por
 lo que si descarga un hrb un hilo que lo haya ejecutado, no afecte a otro que lo
 tenga en uso.
*/

FUNCTION MH_LoadHrb( cHrbFile_or_oHRB )

   LOCAL lResult  := .F.
   LOCAL cType  := ValType( cHrbFile_or_oHRB )
   LOCAL cFile

   DO CASE

   CASE cType == 'C'

      cFile := hb_GetEnv( "PRGPATH" ) + "/" + cHrbFile_or_oHRB

      IF File( cFile )

         WHILE !hb_mutexLock( MH_Mutex() )
         ENDDO
		 
         IF ! hb_HHasKey( ts_hHrbs, cHrbFile_or_oHRB )
            ts_hHrbs[ cHrbFile_or_oHRB ] := hb_hrbLoad( HB_HRB_BIND_OVERLOAD, cFile )
         ENDIF
		 
         hb_mutexUnlock( MH_Mutex() )
      ELSE

         MH_DoError( "MH_LoadHrb() file not found: " + cFile  )

      ENDIF

   CASE cType == 'P'

      ts_hHrbs[ cHrbFile_or_oHRB ] := hb_hrbLoad( HB_HRB_BIND_DEFAULT, hb_GetEnv( "PRGPATH" ) + "/" + cHrbFile_or_oHRB )

   ENDCASE

RETU ''

// ----------------------------------------------------------------//

FUNCTION MH_LoadHrb_Clear()

   LOCAL n

   WHILE !hb_mutexLock( MH_Mutex() )
   ENDDO

   FOR n = 1 TO Len( ts_hHrbs )
      aPair := hb_HPairAt( ts_hHrbs, n )
      hb_hrbUnload( aPair[ 2 ] )
   NEXT
   ts_hHrbs := {=>}	// Really isn't necessary because the thread is closed
   hb_mutexUnlock( MH_Mutex() )

RETU NIL

// ----------------------------------------------------------------//

FUNCTION MH_LoadHrb_Show()

   LOCAL n

   FOR n = 1 TO Len( ts_hHrbs )
      aPair := hb_HPairAt( ts_hHrbs, n )
      _d( aPair[ 1 ], hb_hrbGetFunList( aPair[ 2 ] ) )
   NEXT

RETU NIL

// ----------------------------------------------------------------//

FUNCTION MH_LoadFile( cFile )

   LOCAL cPath_File := hb_GetEnv( "PRGPATH" ) + '/' + cFile

   IF AScan( ts_aFiles, cFile ) > 0
      RETU ''
   ENDIF
   
   if "Linux" $ OS()
      cPath_File = StrTran( cPath_File, '\', '/' )     
   endif      

   IF File( cPath_File )

      AAdd( ts_aFiles, cFile )
      RETURN hb_MemoRead( cPath_File )

   ELSE
      MH_DoError( "MH_LoadFile() file not found: " + cPath_File  )
   ENDIF


RETU ''

// ----------------------------------------------------------------//

FUNCTION MH_ErrorSys( oError, cCode, cCodePP )

	LOCAL hError

	hb_default( @cCode, "" )
	hb_default( @cCodePP, "" )
   
	//	Delete buffer out
   
		ts_cBuffer_Out := ''
		
	//	Recover data info error
	
		hError := MH_ErrorInfo( oError, cCode, cCodePP )
	
	
	IF ValType( ts_bError ) == 'B'

		Eval( ts_bError, hError )

	ELSE

		MH_ErrorShow( hError )

	ENDIF

// Output of buffered text

   ap_RPuts( ts_cBuffer_Out )

   // Unload hrbs loaded.

   mh_LoadHrb_Clear()

// EXIT.----------------

RETU NIL

FUNCTION MH_ErrorBlock( bBlockError )

   ts_bError := bBlockError
   
RETU NIL

// ----------------------------------------------------------------//

FUNCTION MH_DoError( cDescription, cSubsystem )

   LOCAL oError := ErrorNew()

   hb_default( @cSubsystem, "modHarbour.v2" )

   oError:Subsystem   := cSubsystem
   oError:Severity    := 2 // ES_ERROR
   oError:Description := cDescription
   Eval( ErrorBlock(), oError )

RETURN NIL

// ----------------------------------------------------------------//

FUNCTION MH_InitProcess()

	local cPath, cPathFile, cFile
	local aModules 	:= {}	
	
	if !empty( ts_hConfig[ 'modules' ] )		

		cPath 		:= HB_GetEnv( 'PRGPATH' )
		aModules 	:= hb_ATokens( ts_hConfig[ 'modules' ], "," )
		nLen 		:= len(aModules)

		
		for n := 1 to nLen
		
			cFile := aModules[n]
			
			if !empty( cFile ) 			
			
				cPathFile := cPath + '/' + cFile 
				
				if  file( cPathFile )	

					if ! hb_HHasKey( MH_AppModules(), cFile )									
					
						cExt := lower( hb_FNameExt( cFile ) )
						
						
						do case
						
							case cExt == '.hrb'																			
								
								MH_AppModules()[ cFile ] := hb_hrbLoad( HB_HRB_BIND_OVERLOAD, cPathFile ) 
								
							case cExt == '.prg'							
							
								oHrb := MH_Compile( hb_Memoread( cPathFile ) )	

								IF ! Empty( oHrb )

									MH_AppModules()[ cFile ] := hb_hrbLoad( HB_HRB_BIND_OVERLOAD, oHrb )

								ENDIF									
							
							otherwise													
							
						endcase
						
					else
					
						//	Module loaded !											
					
					endif
					
				else

					//	Error ? 
					
					MH_DoError( "MH_InitProcess() file not found: " + cPathFile  )

				endif	
			
			endif 								
		
		next 
		
	endif 	

RETU NIL  

