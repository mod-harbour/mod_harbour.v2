/*
**  mod_harbour.c -- Apache harbour module V2.1
** (c) DHF, 2020-2022
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
#include "apr_general.h"

#define nVms 500

#include <hbapi.h>

#ifdef _WINDOWS_
#include <windows.h>
#else
#include <dlfcn.h>
#include <unistd.h>
#endif

apr_shm_t *mod_harbourV2_shm;
char *shmfilename;
const char * szTempPath;
apr_global_mutex_t *harbour_mutex;
static const char *harbour_mutex_type = "mod_harbour.v2";
typedef struct {
    char *mh_library;
    int mh_nVms;
} _mh_config;

static _mh_config mh_config;

PHB_ITEM hHash;
PHB_ITEM hHashConfig;

typedef int ( * PMH_APACHE )( void * pRequestRec, void * phHash, void * phHashConfig, void * pmh_StartMutex, void * pmh_EndMutex );

#ifdef _WINDOWS_
	HMODULE libmhapache[nVms];
#else
	static void * libmhapache[nVms];
#endif

static int vm[nVms] = {0};

//----------------------------------------------------------------//

static apr_status_t shm_cleanup_wrapper(void *unused)
{
   if (mod_harbourV2_shm)
      return apr_shm_destroy(mod_harbourV2_shm);
   return OK;
}

//----------------------------------------------------------------//

void mh_StartMutex()
{
#ifdef _WINDOWS_
   apr_status_t rs;
   while (1)
   {
      rs = apr_global_mutex_trylock(harbour_mutex);
      if (APR_SUCCESS == rs)
         break;
   };
#endif
}

//----------------------------------------------------------------//

void mh_EndMutex()
{
#ifdef _WINDOWS_
   apr_status_t rs;
   rs = apr_global_mutex_unlock(harbour_mutex);
#endif
}

//----------------------------------------------------------------//

static int mod_harbourV2_pre_config(apr_pool_t *pconf, apr_pool_t *plog,
                                apr_pool_t *ptemp)
{
   ap_mutex_register(pconf, harbour_mutex_type, NULL, APR_LOCK_DEFAULT, 0);
   return OK;
}

//----------------------------------------------------------------//

static int mod_harbourV2_post_config(apr_pool_t *pconf, apr_pool_t *plog,
                                 apr_pool_t *ptemp, server_rec *s)
{
   apr_status_t rs;
	
   if (ap_state_query(AP_SQ_MAIN_STATE) == AP_SQ_MS_CREATE_PRE_CONFIG)
      return OK;

   rs = apr_temp_dir_get(&szTempPath, pconf);

   if (APR_SUCCESS != rs)
   {
      ap_log_error(APLOG_MARK, APLOG_ERR, rs, s, APLOGNO(02992) "Failed to find temporary directory");
      return HTTP_INTERNAL_SERVER_ERROR;
   }

   shmfilename = apr_psprintf(pconf, "%s/httpd_shm.%ld", szTempPath,
                              (long int)getpid());

   rs = ap_global_mutex_create(&harbour_mutex, NULL, harbour_mutex_type, NULL,
                               s, pconf, 0);
   if (APR_SUCCESS != rs)
   {
      return HTTP_INTERNAL_SERVER_ERROR;
   }

   apr_pool_cleanup_register(pconf, NULL, shm_cleanup_wrapper,
                             apr_pool_cleanup_null);

   return OK;
}

//----------------------------------------------------------------//

static void mod_harbourV2_child_init(apr_pool_t *p, server_rec *s)
{
   apr_status_t rs;
	int i;
   
   rs = apr_global_mutex_child_init(&harbour_mutex,
                                    apr_global_mutex_lockfile(harbour_mutex),
                                    p);
   if (APR_SUCCESS != rs)
   {
      ap_log_error(APLOG_MARK, APLOG_CRIT, rs, s, APLOGNO(02994) "Failed to reopen mutex %s in child",
                   harbour_mutex_type);
      exit(1);
   }

   if ( mh_config.mh_library == NULL)
   #ifdef _WINDOWS_
   	mh_config.mh_library = "c:\\xampp\\htdocs\\libmhapache.dll";
   #else
   	#ifdef DARWIN
   	mh_config.mh_library = "/Library/WebServer/Documents/libmhapache.3.2.0.dylib";
	   #else
	   mh_config.mh_library = "/var/www/html/libmhapache.so";
   	#endif
   #endif   

   FILE *file;
   if (!( file = fopen(mh_config.mh_library, "r")) ) {
      ap_log_error(APLOG_MARK, APLOG_CRIT, rs, s, "MH_MESSAGE: MH_LIBRARY %s not found", mh_config.mh_library);
      return HTTP_INTERNAL_SERVER_ERROR;
   }

   fclose(file);

   ap_log_error(APLOG_MARK, APLOG_NOTICE, rs, s, "MH_MESSAGE: Using MH_LIBRARY: %s", mh_config.mh_library);

   if ( mh_config.mh_nVms == NULL )
      mh_config.mh_nVms = 10;

   ap_log_error(APLOG_MARK, APLOG_NOTICE, rs, s, "MH_MESSAGE: Using MH_NVMS: %d", mh_config.mh_nVms);
   
	for ( i = 0; i< mh_config.mh_nVms; i++) {
	#ifdef _WINDOWS_
		CopyFile( mh_config.mh_library, apr_psprintf( p, "%s/%s%d.dll", szTempPath, "libmhapache", i ), 0 );
	#else
		CopyFile( mh_config.mh_library, apr_psprintf( p, "%s/%s%d.so", szTempPath, "libmhapache", i ), 0 );
	#endif
	}
	
	for( i = 0; i < mh_config.mh_nVms; i++ ) {
		#ifdef _WINDOWS_
		libmhapache[i] = LoadLibrary( apr_psprintf( p, "%s/%s%d.dll", szTempPath, "libmhapache", i ) );
		#else
		libmhapache[i] = dlopen( apr_psprintf( p, "%s/%s%d.%s", szTempPath, "libmhapache", i, "so" ), RTLD_NOW );
		#endif
	};	

   hHash = hb_hashNew(NULL);
   hHashConfig = hb_hashNew(NULL);
}

//----------------------------------------------------------------//

const char *ap_getenv(const char *szVarName, request_rec *r)
{
   return apr_table_get(r->subprocess_env, szVarName);
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

#else

//----------------------------------------------------------------//

int CopyFile( const char * from, const char * to, int iOverWrite )
{
    int fd_to, fd_from;
    char buf[ 4096 ];
    ssize_t nread;
    int saved_errno;

    iOverWrite = iOverWrite;

    fd_from = open( from, O_RDONLY );
    if( fd_from < 0 )
        return -1;

    fd_to = open( to, O_WRONLY | O_CREAT | O_EXCL, 0666 );
    if( fd_to < 0 )
        goto out_error;

    while( nread = read( fd_from, buf, sizeof buf ), nread > 0 )
    {
        char * out_ptr = buf;
        ssize_t nwritten;

        do {
            nwritten = write( fd_to, out_ptr, nread );

            if( nwritten >= 0 )
            {
                nread -= nwritten;
                out_ptr += nwritten;
            }
            else if( errno != EINTR )
            {
                goto out_error;
            }
        } while( nread > 0 );
    }

    if( nread == 0 )
    {
        if( close( fd_to ) < 0 )
        {
            fd_to = -1;
            goto out_error;
        }
        close( fd_from );

        return 0;
    }

  out_error:
    saved_errno = errno;

    close( fd_from );
    if( fd_to >= 0 )
        close( fd_to );

    errno = saved_errno;
    return errno;
}
 
#endif

//----------------------------------------------------------------//

const char *mh_lib_set_path(cmd_parms *cmd, void *cfg, const char *arg)
{
    mh_config.mh_library = arg;
    return NULL;
}

//----------------------------------------------------------------//

const char *mh_lib_set_nvms(cmd_parms *cmd, void *cfg, const char *arg)
{
    mh_config.mh_nVms = atoi(arg);
    return NULL;
}

//----------------------------------------------------------------//

static const command_rec mod_harbourV2_params[] =
{
   AP_INIT_TAKE1("MH_LIBRARY", mh_lib_set_path, NULL, RSRC_CONF, "Set the path to the MH library"),
   AP_INIT_TAKE1("MH_NVMS", mh_lib_set_nvms, NULL, RSRC_CONF, "Set number of hb VMs resident"),   
   { NULL }
};

//----------------------------------------------------------------//

static int mod_harbourV2_handler(request_rec *r)
{

	char * szTempFileName = NULL;
	unsigned int dwThreadId;
	apr_status_t rs;
	int nUsedVm = -1;
	int i, iRet = OK;
   
#ifdef _WINDOWS_
	HMODULE libmhapache_vmx = NULL;
#else
	void * libmhapache_vmx = NULL;
#endif
   
   if (strcmp(r->handler, "harbour"))
      return DECLINED;

	PMH_APACHE _mh_apache = NULL;

   r->content_type = "text/html"; //revisar
   r->status = 200;

   ap_add_cgi_vars(r);
   ap_add_common_vars(r);
  
  	while(1) {
        rs = apr_global_mutex_trylock(harbour_mutex);
        if (APR_SUCCESS == rs)
			break;
	};
	
	for( i = 0; i < mh_config.mh_nVms; i++ ) {
		if ( vm[i] == 0 ) {
			nUsedVm = i;
			vm[nUsedVm] = 1;
			break;
		};
	};

	if ( nUsedVm != -1 ) {
	#ifdef _WINDOWS_
		_mh_apache = ( PMH_APACHE ) GetProcAddress( libmhapache[nUsedVm], "mh_apache" );
	#else
		_mh_apache = dlsym( libmhapache[nUsedVm], "mh_apache" );
	#endif
	} else {
	#ifdef _WINDOWS_
		dwThreadId = GetCurrentThreadId();
	#else
		dwThreadId = pthread_self();
	#endif
		CopyFile( mh_config.mh_library, szTempFileName = apr_psprintf( r->pool, "%s/%s.%d.%d", szTempPath, "libmhapache", dwThreadId, ( int ) apr_time_now() ), 0 );
      #ifdef _WINDOWS_
         libmhapache_vmx = LoadLibrary( szTempFileName );
      #else
         libmhapache_vmx = dlopen( szTempFileName, RTLD_LAZY );
      #endif

      #ifdef _WINDOWS_
			_mh_apache = ( PMH_APACHE ) GetProcAddress( libmhapache_vmx, "mh_apache" );
      #else
			_mh_apache = dlsym( libmhapache_vmx, "mh_apache" );
      #endif
	};

	rs = apr_global_mutex_unlock(harbour_mutex);

	iRet = _mh_apache( r, ( PHB_ITEM * ) hHash, ( PHB_ITEM * ) hHashConfig, ( void * ) mh_StartMutex, ( void * ) mh_EndMutex );

	if (nUsedVm != -1) {
		vm[nUsedVm] = 0;
	} else {
	#ifdef _WINDOWS_
		FreeLibrary( libmhapache_vmx );
		DeleteFile( szTempFileName );
	#else
		dlclose( libmhapache_vmx );
		remove( szTempFileName );
	#endif
	};
	return iRet;
}

//----------------------------------------------------------------//

static void mod_harbourV2_register_hooks(apr_pool_t *p)
{
   ap_hook_pre_config(mod_harbourV2_pre_config, NULL, NULL, APR_HOOK_MIDDLE);
   ap_hook_post_config(mod_harbourV2_post_config, NULL, NULL, APR_HOOK_MIDDLE);
   ap_hook_child_init(mod_harbourV2_child_init, NULL, NULL, APR_HOOK_MIDDLE);
   ap_hook_handler(mod_harbourV2_handler, NULL, NULL, APR_HOOK_MIDDLE);
}

//----------------------------------------------------------------//

module AP_MODULE_DECLARE_DATA mod_harbourV2_module = {
    STANDARD20_MODULE_STUFF,
    NULL,
    NULL,
    NULL,
    NULL,
    mod_harbourV2_params,
    mod_harbourV2_register_hooks,
    0};
