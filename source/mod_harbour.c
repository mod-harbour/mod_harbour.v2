/*
**  mod_harbour.c -- Apache harbour module V2
** (c) DHF, 2020-2021
** MIT license
*/

#include "httpd.h"
#include "http_config.h"
#include "http_core.h"
#include "http_log.h"
#include "http_protocol.h"
#include "ap_config.h"
#include "util_script.h"
#include "apr.h"
#include "apr_strings.h"
#include "util_mutex.h"
#include "util_script.h"

#include <hbapiitm.h>
#include <hbapierr.h>
#include <hbapi.h>
#include <hbvm.h>
#include "hbthread.h"
#include "hbxvm.h"

#ifdef _WINDOWS_
   #include <windows.h>
#else
   #include <dlfcn.h>
   #include <unistd.h>
#endif


apr_shm_t *harbourV2_shm; 
char *shmfilename; 
const char *tempdir;
apr_global_mutex_t *harbourV2_mutex;
static const char *harbourV2_mutex_type = "mod_hwapache";
static PHB_ITEM hHash;
static PHB_ITEM hMutex = NULL;

//----------------------------------------------------------------//

static apr_status_t shm_cleanup_wrapper(void *unused)
{
    if (harbourV2_shm)
        return apr_shm_destroy(harbourV2_shm);
    return OK;
}

//----------------------------------------------------------------//

void hw_StartMutex() 
{
#ifdef _WINDOWS_
   apr_status_t rs;    
   while(1) {
      rs = apr_global_mutex_trylock(harbourV2_mutex);
      if (APR_SUCCESS == rs)
         break;
   };
#endif	
}

//----------------------------------------------------------------//

void hw_EndMutex()
{
#ifdef _WINDOWS_
   apr_status_t rs;    
   rs = apr_global_mutex_unlock(harbourV2_mutex);  
#endif	
}

//----------------------------------------------------------------//

static HB_THREAD_STARTFUNC( hb_apache ) {

   hb_vmThreadInit( NULL );
   hb_vmPushDynSym( hb_dynsymFind( "HW_THREAD" ) );
   hb_vmPushNil(); 
   hb_vmPushPointer( Cargo );
   hb_vmFunction( 1 );
   hb_vmThreadQuit();
   HB_THREAD_END
}

//----------------------------------------------------------------//

request_rec * GetRequestRec( void )
{
   hb_vmPushSymbol( hb_dynsymGetSymbol( "GETREQUESTREC" ) );
   hb_vmPushNil();
   hb_vmFunction( 0 );
   return hb_parptr( -1 );
}

//----------------------------------------------------------------//

HB_FUNC( HW_EXITSTATUS )
{
   request_rec *rec = GetRequestRec();
   if( hb_extIsNil( 1 ) ) {
      hb_retni( rec->status );
   } else {
      rec->status = hb_parni( 1 );
   };
}

//----------------------------------------------------------------//

HB_FUNC( HW_STARTMUTEX )
{
   hw_StartMutex();
}

//----------------------------------------------------------------//

HB_FUNC( HW_ENDMUTEX )
{
   hw_EndMutex();
}

//----------------------------------------------------------------//

HB_FUNC( HW_GETBODY )
{
   request_rec * r = GetRequestRec();

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
      }
      else
         hb_retc( "" );
   }
}


//----------------------------------------------------------------//

HB_FUNC( HW_HASH )
{
   hb_itemReturn( hHash );
}

//----------------------------------------------------------------//

HB_FUNC( HW_MUTEX )
{
   hb_itemReturn( hMutex );
}

//----------------------------------------------------------------//


HB_FUNC( HW_WRITE )
{
   hb_retni( ap_rwrite( ( void * ) hb_parc( 1 ), ( int ) hb_parclen( 1 ), GetRequestRec() ) );
}

//----------------------------------------------------------------//

static int harbourV2_pre_config(apr_pool_t *pconf, apr_pool_t *plog,
                            apr_pool_t *ptemp)
{
    ap_mutex_register(pconf, harbourV2_mutex_type, NULL, APR_LOCK_DEFAULT, 0);
    return OK;
}

//----------------------------------------------------------------//

static int harbourV2_post_config(apr_pool_t *pconf, apr_pool_t *plog,
                             apr_pool_t *ptemp, server_rec *s)
{
    apr_status_t rs;

    if (ap_state_query(AP_SQ_MAIN_STATE) == AP_SQ_MS_CREATE_PRE_CONFIG)
        return OK;

    rs = apr_temp_dir_get(&tempdir, pconf);

    if (APR_SUCCESS != rs) {
        ap_log_error(APLOG_MARK, APLOG_ERR, rs, s, APLOGNO(02992)
                     "Failed to find temporary directory");
        return HTTP_INTERNAL_SERVER_ERROR;
    }

    shmfilename = apr_psprintf(pconf, "%s/httpd_shm.%ld", tempdir,
                               (long int)getpid());

    hHash = hb_hashNew( NULL );
    hMutex = hb_threadMutexCreate();

    rs = ap_global_mutex_create(&harbourV2_mutex, NULL, harbourV2_mutex_type, NULL,
                                s, pconf, 0);
    if (APR_SUCCESS != rs) {
        return HTTP_INTERNAL_SERVER_ERROR;
    }

    apr_pool_cleanup_register(pconf, NULL, shm_cleanup_wrapper,
                              apr_pool_cleanup_null);
    return OK;
}

//----------------------------------------------------------------//

static void harbourV2_child_init(apr_pool_t *p, server_rec *s)
{
    apr_status_t rs;

    rs = apr_global_mutex_child_init(&harbourV2_mutex,
                                     apr_global_mutex_lockfile(harbourV2_mutex),
                                     p);
    if (APR_SUCCESS != rs) {
        ap_log_error(APLOG_MARK, APLOG_CRIT, rs, s, APLOGNO(02994)
                     "Failed to reopen mutex %s in child",
                     harbourV2_mutex_type);
        exit(1);
    }
}

//----------------------------------------------------------------//

const char * ap_getenv( const char * szVarName, request_rec * r )
{
   return apr_table_get( r->subprocess_env, szVarName );
}

//----------------------------------------------------------------//

#ifdef _WINDOWS_

char * GetErrorMessage( DWORD dwLastError )
{
   LPVOID lpMsgBuf;

   FormatMessage( FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM,
                  NULL,
                  dwLastError,
                  MAKELANGID( LANG_NEUTRAL, SUBLANG_DEFAULT ), // Default language
                  ( LPTSTR ) &lpMsgBuf,
                  0,
                  NULL );

   return ( ( char * ) lpMsgBuf );
}
 
#endif

//----------------------------------------------------------------//

static int harbourV2_handler( request_rec * r ) {

   HB_THREAD_HANDLE hThread;
   PHB_ITEM pResult = NULL;
   int iResult = OK;

   if( strcmp( r->handler, "harbour" ) )
     return DECLINED;

   r->content_type = "text/html"; //revisar
   r->status = 200;

   ap_add_cgi_vars( r );
   ap_add_common_vars( r );

   hw_StartMutex();
   if( ! hb_vmIsActive() ) {  
      hb_vmInit( HB_FALSE );
   };
   hw_EndMutex();

   hb_vmThreadInit( NULL );
   hb_vmPushDynSym( hb_dynsymFind( "HW_THREAD" ) );
   hb_vmPushNil(); 
   hb_vmPushPointer( r );
   hb_vmFunction( 1 );
   hb_vmThreadQuit();   

   return OK;

}

//----------------------------------------------------------------//

static void harbourV2_register_hooks( apr_pool_t * p )
{
   ap_hook_pre_config(harbourV2_pre_config, NULL, NULL, APR_HOOK_MIDDLE);
   ap_hook_post_config(harbourV2_post_config, NULL, NULL, APR_HOOK_MIDDLE);
   ap_hook_child_init(harbourV2_child_init, NULL, NULL, APR_HOOK_MIDDLE);
   ap_hook_handler( harbourV2_handler, NULL, NULL, APR_HOOK_MIDDLE );
}

//----------------------------------------------------------------//

module AP_MODULE_DECLARE_DATA harbourV2_module = {
    STANDARD20_MODULE_STUFF,
    NULL,                  
    NULL,                  
    NULL,                  
    NULL,                  
    NULL,                  
    harbourV2_register_hooks, 
    0
};
