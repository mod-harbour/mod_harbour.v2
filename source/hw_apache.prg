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
THREAD STATIC _cBuffer_Out  := ''
THREAD STATIC _hHrbs
THREAD STATIC _aFiles
THREAD STATIC _bError
THREAD STATIC _t_hTimer

FUNCTION Main()



RETURN NIL

// ------------------------------------------------------------------ //

FUNCTION HW_Thread( r )

   LOCAL cFileName
   LOCAL pThreadWait
   LOCAL oHrb

   // Init thread statics vars

   request_rec  := r   // Request from Apache
   _cBuffer_Out  := ''   // Buffer for text out
   _hHrbs    := { => }   // Internal hash of loaded hrbs
   _aFiles   := {}   // Internal array of loaded name files

   // ------------------------


   // ErrorBlock( {| oError | GetErrorInfo( oError ), Break( oError ) } )
   ErrorBlock( {| oError | MH_ErrorInfo( oError ), Break( oError ) } )

   _t_hTimer = hb_idleAdd( {|| HW_RequestMaxTime( hb_threadSelf(), 15 ) }  )

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

// Output of buffered text

   AP_RPuts_Out( _cBuffer_Out )

   // Unload hrbs loaded.

   MH_LoadHrb_Clear()

RETURN 1

// ----------------------------------------------------------------//

FUNCTION GetRequestRec()

RETURN request_rec

// ----------------------------------------------------------------//

FUNCTION HW_RequestMaxTime( pThread, nTime )

   sec := Seconds()

   DO WHILE ( Seconds() - sec < nTime )
      hb_idleSleep( 0.01 )
   ENDDO

//   HW_ServerBusy( request_rec )

   while( hb_threadQuitRequest( pThread ) )
      hb_idleSleep( 0.01 )
   ENDDO

RETURN 


// ----------------------------------------------------------------//

FUNCTION AP_RPUTS( ... )

   LOCAL aParams := hb_AParams()
   LOCAL n    := Len( aParams )

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

         WHILE !hb_mutexLock( HW_Mutex() )
         ENDDO
         IF ! hb_HHasKey( _hHrbs, cHrbFile_or_oHRB )
            _hHrbs[ cHrbFile_or_oHRB ] := hb_hrbLoad( 2, cFile )

// Trace
            _d( cHrbFile_or_oHRB, hb_hrbGetFunList( _hHrbs[ cHrbFile_or_oHRB ] ) )

         ENDIF
         hb_mutexUnlock( HW_Mutex() )
      ELSE

         MH_DoError( "MH_LoadHrb() file not found: " + cFile  )

      ENDIF

   CASE cType == 'P'

      _hHrbs[ cHrbFile_or_oHRB ] := hb_hrbLoad( HB_HRB_BIND_DEFAULT, hb_GetEnv( "PRGPATH" ) + "/" + cHrbFile_or_oHRB )

   ENDCASE

   RETU ''

// ----------------------------------------------------------------//

FUNCTION MH_LoadHrb_Clear()

   LOCAL n

   WHILE !hb_mutexLock( HW_Mutex() )
   ENDDO

   FOR n = 1 TO Len( _hHrbs )
      aPair := hb_HPairAt( _hHrbs, n )
      hb_hrbUnload( aPair[ 2 ] )
   NEXT
   _hHrbs := {}
   hb_mutexUnlock( HW_Mutex() )

   RETU NIL

// ----------------------------------------------------------------//

FUNCTION MH_LoadHrb_Show()

   LOCAL n

   FOR n = 1 TO Len( _hHrbs )
      aPair := hb_HPairAt( _hHrbs, n )
      _d( aPair[ 1 ], hb_hrbGetFunList( aPair[ 2 ] ) )
   NEXT

   RETU NIL

// ----------------------------------------------------------------//

FUNCTION MH_LoadFile( cFile )

   LOCAL cPath_File := hb_GetEnv( "PRGPATH" ) + '/' + cFile

   IF AScan( _aFiles, cFile ) > 0
      RETU ''
   ENDIF

   IF File( cPath_File )

      AAdd( _aFiles, cFile )
      RETURN hb_MemoRead( cPath_File )

   ELSE
      MH_DoError( "MH_LoadFile() file not found: " + cPath_File  )
   ENDIF


   RETU ''

// ----------------------------------------------------------------//

FUNCTION MH_ErrorInfo( oError, cCode )

   hb_default( @cCode, "" )

   IF ValType( _bError ) == 'B'

      _cBuffer_Out := ''
      Eval( _bError, oError, cCode )

   ELSE

      GetErrorInfo( oError, @cCode )

   ENDIF

// Output of buffered text

   AP_RPuts_Out( _cBuffer_Out )

   // Unload hrbs loaded.

   MH_LoadHrb_Clear()

// EXIT.----------------

   RETU NIL

FUNCTION MH_ErrorBlock( bBlockError )

   _bError := bBlockError
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
