/*
** mh_apache.prg -- Apache harbour module V2.1
** (c) DHF, 2020-2022
** MIT license
*/


#include "externs.hbx"

#include "hbthread.ch"
#include "hbclass.ch"
#include "hbhrb.ch"
#include "mh_apache.ch"

#define CRLF hb_OsNewLine()

THREAD STATIC ts_cBuffer_Out  := ''
THREAD STATIC ts_hHrbs
THREAD STATIC ts_aFiles
THREAD STATIC ts_bError
THREAD STATIC ts_t_hTimer
THREAD STATIC ts_hConfig
THREAD STATIC ts_oSession
STATIC hPP

// SetEnv Var config. ----------------------------------------
// MH_CACHE    - Use PcodeCached
// MH_TIMEOUT   - Timeout for thread
// MH_PATH_LOG   -  Default HB_GetEnv( 'PRGPATH' )
// MH_PATH_SESSION  -  Default HB_GetEnv( 'DOCUMENT_ROOT' ) + '/.sessions'
// MH_SESSION_SEED -  Default Session Seed
// MH_INITPROCESS  - Init modules at begin of app
// MH_PHPTEMP        -   Path to PHP prepro temp folder. Note: Add write access to folder.
// ------------------------------------------------------------

FUNCTION Main()

   MH_PPRules()

RETURN NIL

FUNCTION MH_PPRules()

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

   ENDIF

RETURN hPP


// ------------------------------------------------------------------ //

FUNCTION MH_Runner()

   LOCAL cFileName, cFilePath, pThreadWait, tFilename, cCode, cCodePP, oHrb
   LOCAL disablecache := .F.

   // Init thread statics vars
   ts_cBuffer_Out := ''    // Buffer for text out
   ts_hHrbs     := { => }  // Internal hash of loaded hrbs
   ts_aFiles    := {}    // Internal array of loaded name files
   ts_oSession  := NIL     // Internal Object Session

   // Init dependent vars of request

   ts_hConfig   := { => }

   ts_hConfig[ 'cache' ] := AP_GetEnv( 'MH_CACHE' ) == '1' .OR. Lower( AP_GetEnv( 'MH_CACHE' ) ) == 'yes'
   ts_hConfig[ 'timeout' ] := Max( Val( AP_GetEnv( 'MH_TIMEOUT' ) ), 15 )

   // ------------------------

   ErrorBlock( {| oError | MH_ErrorSys( oError ), Break( oError ) } )

   ts_t_hTimer = hb_idleAdd( {|| MH_RequestMaxTime( hb_threadSelf(), ts_hConfig[ 'timeout' ] ) }  )

   cFileName = ap_FileName()

   IF File( cFileName )

      cFilePath := SubStr( cFileName, 1, RAt( "/", cFileName ) + RAt( "\", cFileName ) - 1 )

      hb_SetEnv( "PRGPATH", cFilePath )

// We can load different modules at the beginning of our program

      mh_InitProcess()

// ------------------------

      IF Lower( Right( cFileName, 4 ) ) == ".hrb"

         hb_hrbDo( hb_hrbLoad( 2, cFileName ), ap_Args() )

      ELSE // case prg

         cCode := MemoRead( cFileName )

         IF ts_hConfig[ 'cache' ]

            hb_FGetDateTime( cFilename, @tFilename )

            IF ( iif( hb_HHasKey( MH_PcodeCached(), cFilename ), tFilename > MH_PcodeCached()[ cFilename ][ 2 ], .T. ) )

               oHrb := mh_Compile( cCode )

               IF ! Empty( oHrb )

                  MH_PcodeCached()[ cFilename ] = { oHrb, tFilename }

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

      // Output of buffered text

      ap_RPuts( ts_cBuffer_Out )

      // Unload hrbs loaded.

      mh_LoadHrb_Clear()

      // Save session if it exist

      mh_SessionWrite()

   ELSE

      mh_ExitStatus( 404 )

   ENDIF

RETURN mh_ExitStatus()

// ----------------------------------------------------------------//

FUNCTION MH_Config()

RETURN ts_hConfig

// ----------------------------------------------------------------//

FUNCTION MH_oSession( o )

   IF ValType( o ) == 'O'
      ts_oSession := o
   ENDIF

RETURN ts_oSession

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

         IF ! hb_HHasKey( ts_hHrbs, cHrbFile_or_oHRB )
            ts_hHrbs[ cHrbFile_or_oHRB ] := hb_hrbLoad( HB_HRB_BIND_OVERLOAD, cFile )
         ENDIF
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

   FOR n = 1 TO Len( ts_hHrbs )
      aPair := hb_HPairAt( ts_hHrbs, n )
      hb_hrbUnload( aPair[ 2 ] )
   NEXT
   ts_hHrbs := { => } // Really isn't necessary because the thread is closed

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

   IF "Linux" $ OS()
      cPath_File = StrTran( cPath_File, '\', '/' )
   ENDIF

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

// Delete buffer out

   ts_cBuffer_Out := ''

// Recover data info error

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

FUNCTION MH_DoError( cDescription, cSubsystem, nSubCode )

   LOCAL oError := ErrorNew()

   hb_default( @cSubsystem, "modHarbour.v2" )
   hb_default( @nSubCode, 0 )

   oError:Subsystem     := cSubsystem
   oError:SubCode       := nSubCode
   oError:Severity      := 2 // ES_ERROR
   oError:Description   := cDescription
   Eval( ErrorBlock(), oError )

RETURN NIL

// ----------------------------------------------------------------//

FUNCTION MH_InitProcess()

   LOCAL cPath, cPathFile, cFile, cModules
   LOCAL aModules  := {}

   IF !Empty( mh_HashModules() )
      RETU NIL
   ENDIF

   cModules := AP_GetEnv( 'MH_INITPROCESS' )

   IF !Empty( cModules )

      cPath    := hb_GetEnv( 'PRGPATH' )
      aModules := hb_ATokens( cModules, "," )
      nLen     := Len( aModules )

      FOR n := 1 TO nLen

         cFile := aModules[ n ]

         IF !Empty( cFile )

            cPathFile := cPath + '/' + cFile

            IF  File( cPathFile )

               IF ! hb_HHasKey( mh_HashModules(), cFile )

                  cExt := Lower( hb_FNameExt( cFile ) )

                  DO CASE

                  CASE cExt == '.hrb'

                     mh_HashModules()[ cFile ] := hb_hrbLoad( HB_HRB_BIND_OVERLOAD, cPathFile )

                  CASE cExt == '.prg'

                     oHrb := MH_Compile( hb_MemoRead( cPathFile ) )

                     IF ! Empty( oHrb )

                        mh_HashModules()[ cFile ] := hb_hrbLoad( HB_HRB_BIND_OVERLOAD, oHrb )

                     ENDIF

                  CASE cExt == '.ch'

                     mh_HashModules()[ cFile ] := hb_MemoRead( cPathFile )

                  OTHERWISE

                  ENDCASE

               ELSE

// Module loaded !

               ENDIF

            ELSE

// Error ?

               MH_DoError( "MH_InitProcess() file not found: " + cPathFile  )

            ENDIF

         ENDIF

      NEXT

   ENDIF

   MH_AddPPRules()

RETURN NIL

// ----------------------------------------------------------------//

#pragma BEGINDUMP

#include <http_protocol.h>
#include <apr_pools.h>
#include <hbapiitm.h>
#include <hbapierr.h>
#include <hbapi.h>
#include <hbvm.h>
#include "hbthread.h"
#include "hbxvm.h"

PHB_ITEM hPcodeCached;
PHB_ITEM hHashModules;
request_rec * pRequestRec;
char * szBody;
PHB_ITEM * phHash;
PHB_ITEM * phHashConfig;
void * pmh_StartMutex;
void * pmh_EndMutex;

//----------------------------------------------------------------//

#ifdef _WINDOWS_

   #include <windows.h>

   BOOL APIENTRY DllMain( HMODULE hModule, DWORD ul_reason_for_call, LPVOID lpReserved ) {
   hModule = hModule;
   lpReserved = lpReserved;

   switch( ul_reason_for_call ) {
   case DLL_PROCESS_ATTACH:
      hb_vmInit( HB_TRUE );
      hPcodeCached   = hb_hashNew(NULL);
      hHashModules   = hb_hashNew(NULL);
      break;

   case DLL_THREAD_ATTACH:
      break;

   case DLL_THREAD_DETACH:
      break;

   case DLL_PROCESS_DETACH:
      hb_vmQuit();
      break;
   }
   return TRUE;
   }
#else

   void DLL_PROCESS_ATTACH( void ) __attribute__((constructor));
   void DLL_PROCESS_DETACH( void ) __attribute__((destructor));

   void DLL_PROCESS_ATTACH( void ) {
      if( ! hb_vmIsActive() ) {
         hb_vmInit( HB_TRUE );
         hPcodeCached   = hb_hashNew(NULL);
         hHashModules   = hb_hashNew(NULL);
      }
   }

   void DLL_PROCESS_DETACH( void ) {
      hb_vmQuit();
   }

#endif

//----------------------------------------------------------------//

HB_EXPORT_ATTR int mh_apache( request_rec * _pRequestRec, void * _phHash, void * _phHashConfig, void * _pmh_StartMutex, void * _pmh_EndMutex )
{
   szBody = NULL;
   pRequestRec = _pRequestRec;
   phHash = _phHash;
   phHashConfig = _phHashConfig;
   pmh_StartMutex = _pmh_StartMutex;
   pmh_EndMutex = _pmh_EndMutex;

   hb_vmThreadInit( NULL );
   HB_FUNC_EXEC(MH_RUNNER);
   hb_vmThreadQuit();
}

//----------------------------------------------------------------//

request_rec * GetRequestRec( void )
{
   return pRequestRec;
}

//----------------------------------------------------------------//

typedef int ( * MH_STARTMUTEX )( void );
HB_FUNC( MH_STARTMUTEX )
{
   MH_STARTMUTEX mh_StartMutex = ( MH_STARTMUTEX ) pmh_StartMutex;
   mh_StartMutex();
}

//----------------------------------------------------------------//

typedef int ( * MH_ENDMUTEX )( void );
HB_FUNC( MH_ENDMUTEX )
{
   MH_ENDMUTEX mh_EndMutex = ( MH_ENDMUTEX ) pmh_EndMutex;
   mh_EndMutex();
}

//----------------------------------------------------------------//

HB_FUNC( MH_GETBODY )
{
   request_rec * r = GetRequestRec();

   if( szBody )
      hb_retc( szBody );
   else
   {
      if( ap_setup_client_block( r, REQUEST_CHUNKED_ERROR ) != OK )
         hb_retc( "" );
      else
      {
         if( ap_should_client_block( r ) )
         {
            long length = ( long ) r->remaining;
            char * rbuf = ( char * ) apr_pcalloc( r->pool, length + 1 );
            int iRead = 0, iTotal = 0;

            while( ( iRead = ap_get_client_block( r, rbuf + iTotal, length + 1 - iTotal ) ) < ( length + 1 - iTotal ) && iRead != 0 )
            {
               iTotal += iRead;
               iRead = 0;
            }
            hb_retc( rbuf );
            szBody = ( char * ) hb_xgrab( strlen( rbuf ) + 1 );
            strcpy( szBody, rbuf );
         }
         else
            hb_retc( "" );
      }
   }
}

//----------------------------------------------------------------//

HB_FUNC( MH_WRITE )
{
   hb_retni( ap_rwrite( ( void * ) hb_parc( 1 ), ( int ) hb_parclen( 1 ), GetRequestRec() ) );
}

//----------------------------------------------------------------//

HB_FUNC(MH_PCODECACHED)
{
   hb_itemReturn(hPcodeCached);
}

//----------------------------------------------------------------//

HB_FUNC(MH_HASH)
{
   hb_itemReturn(phHash);
}

//----------------------------------------------------------------//

HB_FUNC(MH_HASHCONFIG)
{
   hb_itemReturn(phHashConfig);
}

//----------------------------------------------------------------//

HB_FUNC(MH_HASHMODULES)
{
   hb_itemReturn(hHashModules);
}

//----------------------------------------------------------------//

HB_FUNC(MH_EXITSTATUS)
{
   request_rec *rec = GetRequestRec();
   if (hb_extIsNil(1))
   {
      hb_retni(rec->status);
   }
   else
   {
      rec->status = hb_parni(1);
   };
}

//----------------------------------------------------------------//

#pragma ENDDUMP
