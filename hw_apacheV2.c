/*
**  hw_apacheV2.c -- Apache harbour module V2
** (c) DHF, 2020-2021
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

static HB_THREAD_STARTFUNC( hb_apache ) {

   PHB_ITEM pResult = NULL;
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

HB_FUNC( AP_RPUTS )
{

      PHB_ITEM pItem = hb_param( 1, HB_IT_STRING );

      HB_SIZE nLen;
      HB_BOOL bFreeReq;
      char * buffer = hb_itemString( pItem, &nLen, &bFreeReq );

      ap_rputs( buffer, GetRequestRec() );

      if( bFreeReq )
         hb_xfree( buffer );

      hb_ret();
}

//----------------------------------------------------------------//

HB_FUNC( HW_EXITSTATUS )
{
   request_rec *rec = GetRequestRec();
   rec->status = hb_parni( 1 );
}

//----------------------------------------------------------------//

HB_FUNC( HW_ARGS )
{
   hb_retc( GetRequestRec()->args );
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

HB_FUNC( HW_FILENAME ) {
   hb_retc( GetRequestRec()->filename );
}

//----------------------------------------------------------------//

HB_FUNC( HW_GETENV ) {
   hb_retc( apr_table_get( GetRequestRec()->subprocess_env, hb_parc( 1 ) ) );
}

//----------------------------------------------------------------//

int ap_headers_in_count( void )
{
   return apr_table_elts( GetRequestRec()->headers_in )->nelts;
}

//----------------------------------------------------------------//

HB_FUNC( HW_HEADERSINCOUNT )
{
   hb_retnl( ap_headers_in_count() );
}

//----------------------------------------------------------------//

const char * ap_headers_in_key( int iKey, request_rec * r )
{
   const apr_array_header_t * fields = apr_table_elts( r->headers_in );
   apr_table_entry_t * e = ( apr_table_entry_t * ) fields->elts;

   if( iKey >= 0 && iKey < fields->nelts )
      return e[ iKey ].key;
   else
      return "";
}

//----------------------------------------------------------------//

const char * ap_headers_in_val( int iKey, request_rec * r )
{
   const apr_array_header_t * fields = apr_table_elts( r->headers_in );
   apr_table_entry_t * e = ( apr_table_entry_t * ) fields->elts;

   if( iKey >= 0 && iKey < fields->nelts )
      return e[ iKey ].val;
   else
      return "";
}

//----------------------------------------------------------------//

HB_FUNC( HW_HEADERSINKEY )
{
   hb_retc( ap_headers_in_key( hb_parnl( 1 ), GetRequestRec() ) );
}

//----------------------------------------------------------------//

HB_FUNC( HW_HEADERSINVAL )
{
   hb_retc( ap_headers_in_val( hb_parnl( 1 ), GetRequestRec() ) );
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

int ap_headers_out_count( void )
{
   return apr_table_elts( GetRequestRec()->headers_out )->nelts;
}


//----------------------------------------------------------------//

HB_FUNC( HW_HEADERSOUTCOUNT )
{
   hb_retnl( ap_headers_out_count() );
}

//----------------------------------------------------------------//

const char * ap_headers_out_key( int iKey, request_rec * r )
{
   const apr_array_header_t * fields = apr_table_elts( r->headers_out );
   apr_table_entry_t * e = ( apr_table_entry_t * ) fields->elts;

   if( iKey >= 0 && iKey < fields->nelts )
      return e[ iKey ].key;
   else
      return "";
}

//----------------------------------------------------------------//

const char * ap_headers_out_val( int iKey, request_rec * r )
{
   const apr_array_header_t * fields = apr_table_elts( r->headers_out );
   apr_table_entry_t * e = ( apr_table_entry_t * ) fields->elts;

   if( iKey >= 0 && iKey < fields->nelts )
      return e[ iKey ].val;
   else
      return "";
}

//----------------------------------------------------------------//

HB_FUNC( HW_HEADERSOUTKEY )
{
   hb_retc( ap_headers_out_key( hb_parnl( 1 ), GetRequestRec() ) );
}

//----------------------------------------------------------------//

HB_FUNC( HW_HEADERSOUTVAL )
{
   hb_retc( ap_headers_out_val( hb_parnl( 1 ), GetRequestRec() ) );
}

//----------------------------------------------------------------//

HB_FUNC( HW_HEADERSOUTSET )
{
   apr_table_add( GetRequestRec()->headers_out, hb_parc( 1 ), hb_parc( 2 ) );
}

//----------------------------------------------------------------//

HB_FUNC( HW_HEADERSIN )
{
   PHB_ITEM hHeadersIn = hb_hashNew( NULL );
   request_rec * r = GetRequestRec();
   int iKeys = ap_headers_in_count();

   if( iKeys > 0 )
   {
      int iKey;
      PHB_ITEM pKey = hb_itemNew( NULL );
      PHB_ITEM pValue = hb_itemNew( NULL );

      hb_hashPreallocate( hHeadersIn, iKeys );

      for( iKey = 0; iKey < iKeys; iKey++ )
      {
         hb_itemPutCConst( pKey,   ap_headers_in_key( iKey, r ) );
         hb_itemPutCConst( pValue, ap_headers_in_val( iKey, r ) );
         hb_hashAdd( hHeadersIn, pKey, pValue );
      }

      hb_itemRelease( pKey );
      hb_itemRelease( pValue );
   }

   hb_itemReturnRelease( hHeadersIn );
}

//----------------------------------------------------------------//

HB_FUNC( HW_HEADERSOUT )
{
   PHB_ITEM hHeadersOut = hb_hashNew( NULL );
   request_rec * r = GetRequestRec();
   int iKeys = ap_headers_out_count();

   if( iKeys > 0 )
   {
      int iKey;
      PHB_ITEM pKey = hb_itemNew( NULL );
      PHB_ITEM pValue = hb_itemNew( NULL );

      hb_hashPreallocate( hHeadersOut, iKeys );

      for( iKey = 0; iKey < iKeys; iKey++ )
      {
         hb_itemPutCConst( pKey,   ap_headers_out_key( iKey, r ) );
         hb_itemPutCConst( pValue, ap_headers_out_val( iKey, r ) );
         hb_hashAdd( hHeadersOut, pKey, pValue );
      }

      hb_itemRelease( pKey );
      hb_itemRelease( pValue );
   }

   hb_itemReturnRelease( hHeadersOut );
}

//----------------------------------------------------------------//

HB_FUNC( HW_METHOD )
{
   hb_retc( GetRequestRec()->method );
}

//----------------------------------------------------------------//

HB_FUNC( HW_USERIP )
{
   hb_retc( GetRequestRec()->useragent_ip );
}

HB_FUNC( HW_WRITE )
{
   hb_retni( ap_rwrite( ( void * ) hb_parc( 1 ), ( int ) hb_parclen( 1 ), GetRequestRec() ) );
}

//----------------------------------------------------------------//

HB_FUNC( HW_SETCONTENTTYPE ) // szContentType
{
   request_rec * r = GetRequestRec();
   char * szType = ( char * ) apr_pcalloc( r->pool, hb_parclen( 1 ) + 1 );

   strcpy( szType, hb_parc( 1 ) );
   r->content_type = szType;
}

//----------------------------------------------------------------//

HB_FUNC( HB_URLDECODE ) // Giancarlo's TIP_URLDECODE
{
   const char * pszData = hb_parc( 1 );

   if( pszData )
   {
      HB_ISIZ nLen = hb_parclen( 1 );

      if( nLen )
      {
         HB_ISIZ nPos = 0, nPosRet = 0;

         /* maximum possible length */
         char * pszRet = ( char * ) hb_xgrab( nLen );

         while( nPos < nLen )
         {
            char cElem = pszData[ nPos ];

            if( cElem == '%' && HB_ISXDIGIT( pszData[ nPos + 1 ] ) &&
                                HB_ISXDIGIT( pszData[ nPos + 2 ] ) )
            {
               cElem = pszData[ ++nPos ];
               pszRet[ nPosRet ]  = cElem - ( cElem >= 'a' ? 'a' - 10 :
                                            ( cElem >= 'A' ? 'A' - 10 : '0' ) );
               pszRet[ nPosRet ] <<= 4;
               cElem = pszData[ ++nPos ];
               pszRet[ nPosRet ] |= cElem - ( cElem >= 'a' ? 'a' - 10 :
                                            ( cElem >= 'A' ? 'A' - 10 : '0' ) );
            }
            else
               pszRet[ nPosRet ] = cElem == '+' ? ' ' : cElem;

            nPos++;
            nPosRet++;
         }

         /* this function also adds a zero */
         /* hopefully reduce the size of pszRet */
         hb_retclen_buffer( ( char * ) hb_xrealloc( pszRet, nPosRet + 1 ), nPosRet );
      }
      else
         hb_retc_null();
   }
   else
      hb_errRT_BASE( EG_ARG, 3012, NULL,
                     HB_ERR_FUNCNAME, 1, hb_paramError( 1 ) );
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

   apr_status_t rs;

   HB_THREAD_HANDLE hThread;

   if( strcmp( r->handler, "harbour" ) )
     return DECLINED;

   r->content_type = "text/html"; //revisar

   ap_add_cgi_vars( r );
   ap_add_common_vars( r );

   if( ! hb_vmIsActive() ) {  
      hb_vmInit( HB_TRUE );
   };

   HB_THREAD_ID th_id;
#ifdef _WINDOWS_
   while(1) {
      rs = apr_global_mutex_trylock(harbourV2_mutex);
      if (APR_SUCCESS == rs)
         break;
   };
#endif	
   hThread = hb_threadCreate( &th_id, hb_apache, r );   
   hb_threadJoin( hThread );
#ifdef _WINDOWS_
   rs = apr_global_mutex_unlock(harbourV2_mutex);  
#endif	
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
