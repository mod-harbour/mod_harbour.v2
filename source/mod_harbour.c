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

#define NUM_VMS 500

#include <hbapi.h>

#ifdef _WINDOWS_
#include <windows.h>
#else
#include <dlfcn.h>
#include <unistd.h>
#endif

apr_shm_t *mod_harbourV2_shm;
char *shmfilename;
const char *szTempPath;
apr_global_mutex_t *harbour_mutex;
static const char *harbour_mutex_type = "mod_harbour.v2";
typedef struct
{
   char *mh_library;
   int mh_nVms;
} _mh_config;

static _mh_config mh_config;

PHB_ITEM hHash;
PHB_ITEM hHashConfig;

typedef int (*PMH_APACHE)(void *pRequestRec, void *phHash, void *phHashConfig, void *pmh_StartMutex, void *pmh_EndMutex);

#ifdef _WINDOWS_
HMODULE libmhapache[NUM_VMS];
#else
static void *libmhapache[NUM_VMS];
#endif

static int vm[NUM_VMS] = {0};

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

   if (!hb_fsFileExists(mh_config.mh_library))
   {
      ap_log_error(APLOG_MARK, APLOG_CRIT, rs, s, "MH_MESSAGE: MH_LIBRARY %s not found", mh_config.mh_library);

      return HTTP_INTERNAL_SERVER_ERROR;
   }

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

   if (mh_config.mh_library == NULL)
#ifdef _WINDOWS_
      mh_config.mh_library = "c:\\xampp\\htdocs\\libmhapache.dll";
#else
#ifdef DARWIN
      mh_config.mh_library = "/Library/WebServer/Documents/libmhapache.3.2.0.dylib";
#else
      mh_config.mh_library = "/var/www/html/libmhapache.so";
#endif
#endif

   ap_log_error(APLOG_MARK, APLOG_NOTICE, rs, s, "MH_MESSAGE: Using MH_LIBRARY: %s", mh_config.mh_library);

   if (mh_config.mh_nVms == NULL)
      mh_config.mh_nVms = 10;

   ap_log_error(APLOG_MARK, APLOG_NOTICE, rs, s, "MH_MESSAGE: Using MH_NVMS: %d", mh_config.mh_nVms);

   for (i = 0; i < mh_config.mh_nVms; i++)
   {
      apr_file_copy(mh_config.mh_library, apr_psprintf(p, "%s/%s%d.dll", szTempPath, "libmhapache", i), APR_FILE_SOURCE_PERMS, p);
#ifdef _WINDOWS_
      libmhapache[i] = LoadLibrary(apr_psprintf(p, "%s/%s%d.dll", szTempPath, "libmhapache", i));
#else
      libmhapache[i] = dlopen(apr_psprintf(p, "%s/%s%d.%s", szTempPath, "libmhapache", i, "so"), RTLD_NOW);
#endif
   }

   hHash = hb_hashNew(NULL);
   hHashConfig = hb_hashNew(NULL);
}

//----------------------------------------------------------------//

static const char *mh_lib_set_path(cmd_parms *cmd, void *cfg, const char *arg)
{
   mh_config.mh_library = arg;
   return NULL;
}

//----------------------------------------------------------------//

static const char *mh_lib_set_nvms(cmd_parms *cmd, void *cfg, const char *arg)
{
   mh_config.mh_nVms = atoi(arg);
   return NULL;
}

//----------------------------------------------------------------//

static const command_rec mod_harbourV2_params[] =
    {
        AP_INIT_TAKE1("MH_LIBRARY", mh_lib_set_path, NULL, RSRC_CONF, "Set the path to the MH library"),
        AP_INIT_TAKE1("MH_NVMS", mh_lib_set_nvms, NULL, RSRC_CONF, "Set number of hb VMs resident"),
        {NULL}};

//----------------------------------------------------------------//

static int mod_harbourV2_handler(request_rec *r)
{

   char *szTempFileName = NULL;
   unsigned int dwThreadId;
   int nUsedVm = -1;
   int i, iRet = OK;

#ifdef _WINDOWS_
   HMODULE libmhapache_vmx = NULL;
#else
   void *libmhapache_vmx = NULL;
#endif

   if (strcmp(r->handler, "harbour"))
      return DECLINED;

   PMH_APACHE _mh_apache = NULL;

   r->content_type = "text/html"; // revisar
   r->status = 200;

   ap_add_cgi_vars(r);
   ap_add_common_vars(r);

   mh_StartMutex();

   for (i = 0; i < mh_config.mh_nVms; i++)
   {
      if (vm[i] == 0)
      {
         nUsedVm = i;
         vm[nUsedVm] = 1;
         break;
      }
   }

   if (nUsedVm != -1)
   {
#ifdef _WINDOWS_
      _mh_apache = (PMH_APACHE)GetProcAddress(libmhapache[nUsedVm], "mh_apache");
#else
      _mh_apache = dlsym(libmhapache[nUsedVm], "mh_apache");
#endif
   }
   else
   {
#ifdef _WINDOWS_
      dwThreadId = GetCurrentThreadId();
#else
      dwThreadId = pthread_self();
#endif
      CopyFile(mh_config.mh_library, szTempFileName = apr_psprintf(r->pool, "%s/%s.%d.%d", szTempPath, "libmhapache", dwThreadId, (int)apr_time_now()), 0);
#ifdef _WINDOWS_
      libmhapache_vmx = LoadLibrary(szTempFileName);
#else
      libmhapache_vmx = dlopen(szTempFileName, RTLD_LAZY);
#endif

#ifdef _WINDOWS_
      _mh_apache = (PMH_APACHE)GetProcAddress(libmhapache_vmx, "mh_apache");
#else
      _mh_apache = dlsym(libmhapache_vmx, "mh_apache");
#endif
   }

   mh_EndMutex();

   iRet = _mh_apache(r, (PHB_ITEM *)hHash, (PHB_ITEM *)hHashConfig, (void *)mh_StartMutex, (void *)mh_EndMutex);

   if (nUsedVm != -1)
   {
      vm[nUsedVm] = 0;
   }
   else
   {
#ifdef _WINDOWS_
      FreeLibrary(libmhapache_vmx);
      DeleteFile(szTempFileName);
#else
      dlclose(libmhapache_vmx);
      remove(szTempFileName);
#endif
   }
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
    mod_harbourV2_register_hooks};
