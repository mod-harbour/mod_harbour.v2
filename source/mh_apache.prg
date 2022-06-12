/*
** mh_apache.prg -- Apache harbour module V2.1.1
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
THREAD STATIC ts_hConfig
THREAD STATIC ts_oSession
THREAD STATIC hPP

// SetEnv Var config. ----------------------------------------
// MH_CACHE          - Use PcodeCached
// MH_TIMEOUT        - Timeout for thread( must be >= 15 sec )
// MH_PATH_LOG       - Default HB_GetEnv( 'PRGPATH' )
// MH_PATH_SESSION   - Default HB_GetEnv( 'DOCUMENT_ROOT' ) + '/.sessions'
// MH_SESSION_SEED   - Default Session Seed
// MH_INITPROCESS    - Init modules at begin of app
// MH_PHPTEMP        - Path to PHP prepro temp folder. Note: Add write access to folder.
// MH_MINIMALVERSION - Set minimal version for execute, ex. 2.1.005
// MH_DEBUG_ERROR    - If yes/on/1  when error, output to DBWin error traces
// ------------------------------------------------------------

FUNCTION Main()

   mh_PPRules()

RETURN NIL

FUNCTION mh_PPRules()

   LOCAL cOs := OS()
   LOCAL n, aPair, cExt
 

    IF hPP == nil

      hPP := __pp_Init()

      DO CASE
      CASE "Windows" $ cOs  ; __pp_Path( hPP, "c:\harbour\include" )
      CASE "Linux" $ cOs   ; __pp_Path( hPP, "~/harbour/include" )
      ENDCASE

      __pp_AddRule( hPP, "#xcommand static [<explist,...>]  => THREAD STATIC [<explist>]" )
      __pp_AddRule( hPP, "#xcommand THREAD STATIC function <FuncName>([<params,...>]) => STAT FUNCTION <FuncName>( [<params>] )" )
      __pp_AddRule( hPP, "#xcommand THREAD STATIC procedure <ProcName>([<params,...>]) => STAT PROCEDURE <ProcName>( [<params>] )" )
	  
      __pp_AddRule( hPP, "#define __MODHARBOUR__" )
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
	
	IF ! Empty( hb_GetEnv( "HB_INCLUDE" ) )
	  __pp_Path( hPP, hb_GetEnv( "HB_INCLUDE" ) )
	ENDIF			 


RETURN hPP


// ------------------------------------------------------------------ //

FUNCTION mh_Runner()

   LOCAL cFileName, cFilePath, pThreadWait, tFilename, cCode, cCodePP, oHrb, cExt
   LOCAL disablecache := .F.

   // Init thread statics vars
   ts_cBuffer_Out := ''    // Buffer for text out
   ts_hHrbs     := { => }  // Internal hash of loaded hrbs
   ts_aFiles    := {}    // Internal array of loaded name files
   ts_oSession  := NIL     // Internal Object Session

   // Init dependent vars of request

   ts_hConfig   := { => }

   ts_hConfig[ 'cache' ] := AP_GetEnv( 'MH_CACHE' ) == '1' .OR. Lower( AP_GetEnv( 'MH_CACHE' ) ) == 'yes'
   ts_hConfig[ 'timeout' ] := Val( AP_GetEnv( 'MH_TIMEOUT' ) ) // 15 Sec max

   // ------------------------

   ErrorBlock( {| oError | mh_ErrorSys( oError ), Break( oError ) } )

   IF ( ts_hConfig[ 'timeout' ] != 0 )
      pThreadWait := hb_threadStart( @mh_RequestMaxTime(), hb_threadSelf(), ts_hConfig[ 'timeout' ] )
   ENDIF

   cFileName = ap_FileName()

   IF File( cFileName )

      cFilePath := SubStr( cFileName, 1, RAt( "/", cFileName ) + RAt( "\", cFileName ) - 1 )

      hb_SetEnv( "PRGPATH", cFilePath )


      mh_InitProcess()		//	We can load different modules at the beginning of our program
	  mh_MinimalVersion()		//	Check if required a minimal version of mod

      cExt := Lower( hb_FNameExt( cFileName ) )

      SWITCH cExt

      CASE ".hrb"

         hb_hrbDo( hb_hrbLoad( 2, cFileName ), ap_Args() )
         EXIT

      CASE ".prg"

         cCode := hb_MemoRead( cFileName )

         IF ts_hConfig[ 'cache' ]

            hb_FGetDateTime( cFilename, @tFilename )

            IF ( iif( hb_HHasKey( mh_PcodeCached(), cFilename ), tFilename > mh_PcodeCached()[ cFilename ][ 2 ], .T. ) )

               oHrb := mh_Compile( cCode )

               IF ! Empty( oHrb )

                  mh_PcodeCached()[ cFilename ] = { oHrb, tFilename }

               ENDIF

            ELSE

               oHrb = mh_PcodeCached()[ cFilename ][ 1 ]

            ENDIF

            IF ! Empty( oHrb )

               uRet := hb_hrbDo( hb_hrbLoad( HB_HRB_BIND_OVERLOAD, oHrb ), ap_Args()  )

            ENDIF


         ELSE

            mh_Execute( cCode, ap_Args() )

         ENDIF

         EXIT

      CASE ".view"

         ap_Echo( MH_InlinePRG( mh_View( hb_FNameNameExt( cFileName ), iif( !Empty( ap_GetPairs() ), ap_GetPairs(), ap_PostPairs() ) ) ) )

         EXIT

      ENDSWITCH

      // Output of buffered text

      ap_RPuts( ts_cBuffer_Out )

      // Unload hrbs loaded.

      mh_LoadHrb_Clear()

      // Save session if it exist

      mh_SessionWrite()

   ELSE

      mh_ExitStatus( 404 )

   ENDIF

RETURN

// ----------------------------------------------------------------//

FUNCTION mh_Config()

RETURN ts_hConfig

// ----------------------------------------------------------------//

FUNCTION mh_oSession( o )

   IF ValType( o ) == 'O'
      ts_oSession := o
   ENDIF

RETURN ts_oSession

// ----------------------------------------------------------------//

FUNCTION mh_RequestMaxTime( pThread, nTime )

   hb_idleSleep( nTime )

   mh_ExitStatus( 508 )

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

FUNCTION mh_LoadHrb( cHrbFile_or_oHRB )

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

         mh_DoError( "MH_LoadHrb() file not found: " + cFile  )

      ENDIF

   CASE cType == 'P'

      ts_hHrbs[ cHrbFile_or_oHRB ] := hb_hrbLoad( HB_HRB_BIND_DEFAULT, hb_GetEnv( "PRGPATH" ) + "/" + cHrbFile_or_oHRB )

   ENDCASE

   RETU ''

// ----------------------------------------------------------------//

FUNCTION mh_LoadHrb_Clear()

   LOCAL n

   FOR n = 1 TO Len( ts_hHrbs )
      aPair := hb_HPairAt( ts_hHrbs, n )
      hb_hrbUnload( aPair[ 2 ] )
   NEXT
   ts_hHrbs := { => } // Really isn't necessary because the thread is closed

   RETU NIL

// ----------------------------------------------------------------//

FUNCTION mh_LoadHrb_Show()

   LOCAL n

   FOR n = 1 TO Len( ts_hHrbs )
      aPair := hb_HPairAt( ts_hHrbs, n )
      _d( aPair[ 1 ], hb_hrbGetFunList( aPair[ 2 ] ) )
   NEXT

   RETU NIL

// ----------------------------------------------------------------//

FUNCTION mh_LoadFile( cFile )

   LOCAL cPath_File 
   
   cFile := lower( cFile )
   
   cPath_File := hb_GetEnv( "PRGPATH" ) + '/' + cFile

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
      mh_DoError( "mh_LoadFile() file not found: " + cPath_File  )
   ENDIF


   RETU ''

// ----------------------------------------------------------------//

FUNCTION mh_View( cFile, ... )

   LOCAL cPath_File  := hb_GetEnv( "PRGPATH" ) + '/' + cFile
   LOCAL cCode   := ''

   IF "Linux" $ OS()
      cPath_File = StrTran( cPath_File, '\', '/' )
   ENDIF

   IF File( cPath_File )

      cCode := mh_ReplaceBlocks( hb_MemoRead( cPath_File ), '{{', '}}', '', ... )

   ELSE
      mh_DoError( "mh_View() file not found: " + cPath_File  )
   ENDIF

   RETU cCode

// ----------------------------------------------------------------//

FUNCTION mh_Css( cFile )

   LOCAL cPath_File  := hb_GetEnv( "PRGPATH" ) + '/' + cFile
   LOCAL cCode   := ''

   IF "Linux" $ OS()
      cPath_File = StrTran( cPath_File, '\', '/' )
   ENDIF

   IF File( cPath_File )

      cCode := '<style>'
      cCode += hb_MemoRead( cPath_File )
      cCode += '</style>'
   ELSE
      mh_DoError( "mh_Css() file not found: " + cPath_File  )
   ENDIF

   RETU cCode


// ----------------------------------------------------------------//

FUNCTION mh_Js( cFile )

   LOCAL cPath_File  := hb_GetEnv( "PRGPATH" ) + '/' + cFile
   LOCAL cCode   := ''

   IF "Linux" $ OS()
      cPath_File = StrTran( cPath_File, '\', '/' )
   ENDIF

   IF File( cPath_File )

      cCode := '<script>'
      cCode += hb_MemoRead( cPath_File )
      cCode += '</script>'
   ELSE
      mh_DoError( "mh_Js() file not found: " + cPath_File  )
   ENDIF

   RETU cCode


// ----------------------------------------------------------------//

FUNCTION mh_ErrorSys( oError, cCode, cCodePP )

   LOCAL hError

   hb_default( @cCode, "" )
   hb_default( @cCodePP, "" )

// Delete buffer out

   ts_cBuffer_Out := ''

// Recover data info error

   hError := mh_ErrorInfo( oError, cCode, cCodePP )


   IF ValType( ts_bError ) == 'B'

      Eval( ts_bError, hError, oError )

   ELSE

      mh_ErrorShow( hError, oError )

   ENDIF

// Output of buffered text

   ap_RPuts( ts_cBuffer_Out )

   // Unload hrbs loaded.

   mh_LoadHrb_Clear()

// EXIT.----------------

   RETU NIL

FUNCTION mh_ErrorBlock( bBlockError )

   ts_bError := bBlockError

   RETU NIL

// ----------------------------------------------------------------//

FUNCTION mh_DoError( cDescription, cSubsystem, nSubCode )

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

FUNCTION mh_InitProcess()

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
					 
					IF lower( HB_FNameName( cPathFile ) ) == 'init' 							
						hb_hrbDo( mh_HashModules()[ cFile ] )							
					ENDIF 					 

                  CASE cExt == '.prg'

                     oHrb := mh_Compile( hb_MemoRead( cPathFile ) )

                     IF ! Empty( oHrb )

                        mh_HashModules()[ cFile ] := hb_hrbLoad( HB_HRB_BIND_OVERLOAD, oHrb )
						
						IF lower( HB_FNameName( cPathFile ) ) == 'init' 							
							hb_hrbDo( mh_HashModules()[ cFile ] )							
						ENDIF 

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

               mh_DoError( "mh_InitProcess() file not found: " + cPathFile  )

            ENDIF

         ENDIF

      NEXT

   ENDIF

   mh_AddPPRules()

RETURN NIL

// ----------------------------------------------------------------//

FUNCTION mh_MinimalVersion()

    LOCAL cMinVersion := AP_GetEnv( 'MH_MINIMALVERSION' )   	
	
	IF !empty( cMinVersion ) .AND. mh_modversion() < cMinVersion		
		
		mh_DoError('Minimal version modHarbour required: ' + cMinVersion + ;
					'<br>' + 'Version actual: ' + mh_modversion() )
		__Quit() 					
	
	ENDIF

RETURN NIL

// ----------------------------------------------------------------//

FUNCTION mh_GetUri()

   LOCAL cUri

   IF !Empty( ap_GetEnv( 'HTTPS' ) ) .AND. ( 'on' == ap_GetEnv( 'HTTPS' ) )
      cUri := 'https://'
   ELSE
      cUri := 'http://'
   ENDIF

   cUri += ap_GetEnv( 'HTTP_HOST' ) + hb_FNameDir( ap_GetEnv( 'SCRIPT_NAME' ) )

   RETU cUri

// ----------------------------------------------------------------//

FUNCTION mh_Redirect( cUrl )

   ap_HeadersOutSet( "Location", cUrl  )

   mh_ExitStatus( 302 )

   RETU NIL

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
int nUsedVm;

//----------------------------------------------------------------//

#ifdef _WINDOWS_

#include <windows.h>

#endif

//----------------------------------------------------------------//

HB_EXPORT_ATTR void mh_init( void * _phHash, void * _phHashConfig, void * _pmh_StartMutex, void * _pmh_EndMutex )
{
   if( ! hb_vmIsActive() ) {
      hb_vmInit( HB_TRUE );
      if ( _phHash != NULL ) {
          phHash = _phHash;
          phHashConfig = _phHashConfig;
      };
      hPcodeCached   = hb_hashNew(NULL);
      hHashModules   = hb_hashNew(NULL);
      pmh_StartMutex = _pmh_StartMutex;
      pmh_EndMutex = _pmh_EndMutex;
   };
}

//----------------------------------------------------------------//

HB_EXPORT_ATTR PHB_ITEM mh_HashInit( void * _phHash )
{
   phHash = hb_hashNew(NULL);
   return phHash;
}

//----------------------------------------------------------------//

HB_EXPORT_ATTR PHB_ITEM mh_HashConfigInit( void * _phHashConfig )
{
   phHashConfig = hb_hashNew(NULL);
   return phHashConfig;
}

//----------------------------------------------------------------//

HB_EXPORT_ATTR void mh_apache( request_rec * _pRequestRec, int _nUsedVm )
{
   szBody = NULL;
   pRequestRec = _pRequestRec;
   nUsedVm = _nUsedVm;      
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

HB_FUNC( MH_USEDVM )
{
   hb_retni( nUsedVm );
}

//----------------------------------------------------------------//

#pragma ENDDUMP
