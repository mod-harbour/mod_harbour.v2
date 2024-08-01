/*
**  ap_func_c.c -- Apache API in wrappers
**
*/

#include <http_request.h> // add:WenSheng:2023.05.24
#include <http_protocol.h>
#include <apr_pools.h>
#include <util_cookies.h>
#include <util_script.h>
#include <apr_strings.h>
#include <hbapi.h>
#include <hbapiitm.h>

request_rec *GetRequestRec(void);

typedef struct
{
   const char *key;
   const char *value;
} keyValuePair;

//----------------------------------------------------------------//

const char *ap_headers_in_key(int iKey)
{
   const apr_array_header_t *fields = apr_table_elts(GetRequestRec()->headers_in);
   apr_table_entry_t *e = (apr_table_entry_t *)fields->elts;

   if (iKey >= 0 && iKey < fields->nelts)
      return e[iKey].key;
   else
      return "";
}

//----------------------------------------------------------------//

HB_FUNC(AP_HEADERSINKEY)
{
   hb_retc(ap_headers_in_key(hb_parnl(1)));
}

//----------------------------------------------------------------//

const char *ap_headers_in_val(int iKey)
{
   const apr_array_header_t *fields = apr_table_elts(GetRequestRec()->headers_in);
   apr_table_entry_t *e = (apr_table_entry_t *)fields->elts;

   if (iKey >= 0 && iKey < fields->nelts)
      return e[iKey].val;
   else
      return "";
}

//----------------------------------------------------------------//

const char *ap_headers_out_key(int iKey)
{
   const apr_array_header_t *fields = apr_table_elts(GetRequestRec()->headers_out);
   apr_table_entry_t *e = (apr_table_entry_t *)fields->elts;

   if (iKey >= 0 && iKey < fields->nelts)
      return e[iKey].key;
   else
      return "";
}

//----------------------------------------------------------------//

const char *ap_headers_out_val(int iKey)
{
   const apr_array_header_t *fields = apr_table_elts(GetRequestRec()->headers_out);
   apr_table_entry_t *e = (apr_table_entry_t *)fields->elts;

   if (iKey >= 0 && iKey < fields->nelts)
      return e[iKey].val;
   else
      return "";
}

//----------------------------------------------------------------//

HB_FUNC(AP_HEADERSIN)
{
   PHB_ITEM hHeadersIn = hb_hashNew(NULL);
   int iKeys = apr_table_elts(GetRequestRec()->headers_in)->nelts;

   if (iKeys > 0)
   {
      int iKey;
      PHB_ITEM pKey = hb_itemNew(NULL);
      PHB_ITEM pValue = hb_itemNew(NULL);

      hb_hashPreallocate(hHeadersIn, iKeys);

      for (iKey = 0; iKey < iKeys; iKey++)
      {
         hb_itemPutCConst(pKey, ap_headers_in_key(iKey));
         hb_itemPutCConst(pValue, ap_headers_in_val(iKey));
         hb_hashAdd(hHeadersIn, pKey, pValue);
      }

      hb_itemRelease(pKey);
      hb_itemRelease(pValue);
   }

   hb_itemReturnRelease(hHeadersIn);
}

//----------------------------------------------------------------//

HB_FUNC(AP_HEADERSOUT)
{
   PHB_ITEM hHeadersOut = hb_hashNew(NULL);
   int iKeys = apr_table_elts(GetRequestRec()->headers_out)->nelts;

   if (iKeys > 0)
   {
      int iKey;
      PHB_ITEM pKey = hb_itemNew(NULL);
      PHB_ITEM pValue = hb_itemNew(NULL);

      hb_hashPreallocate(hHeadersOut, iKeys);

      for (iKey = 0; iKey < iKeys; iKey++)
      {
         hb_itemPutCConst(pKey, ap_headers_out_key(iKey));
         hb_itemPutCConst(pValue, ap_headers_out_val(iKey));
         hb_hashAdd(hHeadersOut, pKey, pValue);
      }

      hb_itemRelease(pKey);
      hb_itemRelease(pValue);
   }

   hb_itemReturnRelease(hHeadersOut);
}

//----------------------------------------------------------------//

HB_FUNC(AP_ARGS)
{
   hb_retc(GetRequestRec()->args);
}

//----------------------------------------------------------------//

HB_FUNC(AP_GETBODY)
{
   request_rec *r = GetRequestRec();

   if (ap_setup_client_block(r, REQUEST_CHUNKED_ERROR) != OK)
      hb_retc("");
   else
   {
      if (ap_should_client_block(r))
      {
         long length = (long)r->remaining;
         char *rbuf = (char *)apr_pcalloc(r->pool, length + 1);
         int iRead = 0, iTotal = 0;

         while ((iRead = ap_get_client_block(r, rbuf + iTotal, length + 1 - iTotal)) < (length + 1 - iTotal) && iRead != 0)
         {
            iTotal += iRead;
            iRead = 0;
         }
         hb_retc(rbuf);
      }
      else
         hb_retc("");
   }
}

//----------------------------------------------------------------//

HB_FUNC(AP_FILENAME)
{
   hb_retc(GetRequestRec()->filename);
}

//----------------------------------------------------------------//

HB_FUNC(AP_GETENV)
{
   hb_retc(apr_table_get(GetRequestRec()->subprocess_env, hb_parc(1)));
}

//----------------------------------------------------------------//

HB_FUNC(AP_HEADERSINVAL)
{
   hb_retc(ap_headers_in_val(hb_parnl(1)));
}

//----------------------------------------------------------------//

HB_FUNC(AP_METHOD)
{
   hb_retc(GetRequestRec()->method);
}

//----------------------------------------------------------------//

HB_FUNC(AP_USERIP)
{
   hb_retc(GetRequestRec()->useragent_ip);
}

//----------------------------------------------------------------//

HB_FUNC(AP_HEADERSOUTKEY)
{
   hb_retc(ap_headers_out_key(hb_parnl(1)));
}

//----------------------------------------------------------------//

HB_FUNC(AP_HEADERSOUTVAL)
{
   hb_retc(ap_headers_out_val(hb_parnl(1)));
}

//----------------------------------------------------------------//

HB_FUNC(AP_HEADERSOUTSET)
{
   apr_table_add(GetRequestRec()->headers_out, hb_parc(1), hb_parc(2));
}

//----------------------------------------------------------------//

HB_FUNC(AP_RWRITE)
{
   hb_retni(ap_rwrite((void *)hb_parc(1), (int)hb_parclen(1), GetRequestRec()));
}

//----------------------------------------------------------------//

HB_FUNC(AP_SETCONTENTTYPE) // szContentType
{
   request_rec *r = GetRequestRec();
   char *szType = (char *)apr_pcalloc(r->pool, hb_parclen(1) + 1);

   strcpy(szType, hb_parc(1));
   r->content_type = szType;
}

//----------------------------------------------------------------//

HB_FUNC(AP_HEADERSINCOUNT)
{
   hb_retnl(apr_table_elts(GetRequestRec()->headers_in)->nelts);
}

//----------------------------------------------------------------//

HB_FUNC(AP_HEADERSOUTCOUNT)
{
   hb_retnl(apr_table_elts(GetRequestRec()->headers_out)->nelts);
}

//----------------------------------------------------------------//
HB_FUNC(AP_COOKIE_REMOVE)
{
   request_rec *r = GetRequestRec();
   ap_cookie_remove(r, hb_parc(1), NULL, r->headers_out, r->err_headers_out, NULL);
}

//----------------------------------------------------------------//

HB_FUNC(AP_COOKIE_READ)
{
   const char *val = NULL;
   apr_status_t rs;
   request_rec *r = GetRequestRec();
   rs = ap_cookie_read(r, hb_parc(1), &val, hb_parldef(2, 0));
   if (APR_SUCCESS != rs)
      hb_retc(val);
   else
      hb_retl(0);
}

//----------------------------------------------------------------//

HB_FUNC(AP_COOKIE_WRITE)
{
   request_rec *r = GetRequestRec();
   ap_cookie_write(r, hb_parc(1), hb_parc(2), NULL, 60, r->headers_out, r->err_headers_out, NULL);
}

//----------------------------------------------------------------//

HB_FUNC(AP_COOKIE_CHECK_STRING)
{
   apr_status_t rs;
   rs = ap_cookie_check_string(hb_parc(1));
   if (APR_SUCCESS != rs)
      hb_retl(0);
   else
      hb_retl(1);
}

HB_FUNC(AP_ARGS_TO_TABLE) //Parse Get values to hash
{
   PHB_ITEM hGetParam = hb_hashNew(NULL);

   request_rec *r = GetRequestRec();
   apr_table_t *getTable = NULL;
   ap_args_to_table(r, &getTable);
   const apr_array_header_t *getParams = apr_table_elts(getTable);
   apr_table_entry_t *getParam = (apr_table_entry_t *)getParams->elts;

   PHB_ITEM pKey = hb_itemNew(NULL);
   PHB_ITEM pValue = hb_itemNew(NULL);
   hb_hashPreallocate(hGetParam, getParams->nelts);

   for (int i = 0; i < getParams->nelts; i++)
   {
      hb_itemPutCConst(pKey, getParam[i].key);
      hb_itemPutCConst(pValue, getParam[i].val);
      hb_hashAdd(hGetParam, pKey, pValue);
   };

   hb_itemRelease(pKey);
   hb_itemRelease(pValue);
   hb_itemReturnRelease(hGetParam);
}

keyValuePair *mh_ReadPost(request_rec *r, int *nCount)
{
   apr_array_header_t *pairs = NULL;
   apr_off_t len;
   apr_size_t size;
   int res;
   int i = 0;
   char *buffer;
   keyValuePair *kvp;

   res = ap_parse_form_data(r, NULL, &pairs, (size_t) -1, HUGE_STRING_LEN);
   if (res != OK || !pairs)
      return NULL; 
   kvp = apr_pcalloc(r->pool, sizeof(keyValuePair) * (pairs->nelts + 1));
   while (pairs && !apr_is_empty_array(pairs))
   {
      ap_form_pair_t *pair = (ap_form_pair_t *)apr_array_pop(pairs);
      apr_brigade_length(pair->value, 1, &len);
      size = (apr_size_t)len;
      buffer = apr_palloc(r->pool, size + 1);
      apr_brigade_flatten(pair->value, buffer, &size);
      buffer[len] = 0;
      kvp[i].key = apr_pstrdup(r->pool, pair->name);
      kvp[i].value = buffer;
      i++;
   }
   *nCount = i;
   
   return kvp;
}

HB_FUNC(AP_PARSE_FROM_DATA) //Parse Post values to hash. NOTE: Should not be called after AP_BODY()
{
   PHB_ITEM hPostParam = hb_hashNew(NULL);
   request_rec *r = GetRequestRec();
   int nCount = 0;
   keyValuePair *formData;
   formData = mh_ReadPost(r, &nCount);
   
   if (formData) {
      
      PHB_ITEM pKey = hb_itemNew(NULL);
      PHB_ITEM pValue = hb_itemNew(NULL);
      hb_hashPreallocate(hPostParam, nCount);      

      int i;
      for (i = 0; &formData[i]; i++)
      {
         if (formData[i].key && formData[i].value)
         {
            hb_itemPutCConst(pKey, formData[i].key);
            hb_itemPutCConst(pValue, formData[i].value);
         }
         else if (formData[i].key)
         {
            hb_itemPutCConst(pKey, formData[i].key);
            hb_itemPutCConst(pValue, "NIL");
         }
         else if (formData[i].value)
         {
            hb_itemPutCConst(pKey, "NIL");
            hb_itemPutCConst(pValue, formData[i].value);
         }
         else
         {
            break;
         }
         hb_hashAdd(hPostParam, pKey, pValue);
      }
      hb_itemRelease(pKey);
      hb_itemRelease(pValue);
   }

   hb_itemReturnRelease(hPostParam);   
}

/*
	add:WenSheng:2023.05.24: 
	void ap_internal_redirect (const char *new_uri, request_rec *r) docstore.mik.ua/orelly/apache_mod/141.htm
*/
HB_FUNC( AP_REDIRECT )
{
  ap_internal_redirect( ( const char * ) hb_parc( 1 ), GetRequestRec() );
  hb_ret();
}
// int ap_rflush (request_rec *r) docstore.mik.ua/orelly/apache_mod/137.htm
HB_FUNC( AP_RFLUSH )
{
  hb_retni( (int) ap_rflush( GetRequestRec() ) );
  hb_ret();
}
// add:WenSheng:is connection still open?
HB_FUNC( AP_CONNECTION_ABORTED )
{
  unsigned aborted;
  aborted = GetRequestRec()->connection->aborted;
  if(aborted){
  	hb_retl(HB_TRUE);
  }else{
  	hb_retl(HB_FALSE);
  }
}
// server IP address
HB_FUNC( AP_LOCAL_IP )
{
  char * local_ip = GetRequestRec()->connection->local_ip;
 	hb_retc(local_ip);
}
// used for ap_get_server_name when UseCanonicalName is set to DNS (ignores setting of HostnameLookups)
HB_FUNC( AP_LOCAL_HOST )
{
  char * local_host = GetRequestRec()->connection->local_host;
 	hb_retc(local_host);
}
HB_FUNC( AP_CLIENT_IP )
{
  char * client_ip = GetRequestRec()->connection->client_ip;
 	hb_retc(client_ip);
}
/*
	char *remote_host This field may contain the DNS name of the client. The various caveats described in Chapter 9, Perl API Reference Guide, for the remote_host() method of the Apache::Connection class also apply here. It is almost always a better idea to use the high-level API call ap_ get_remote_host() than to access this field directly.
*/
HB_FUNC( AP_REMOTE_HOST )
{
  char * remote_host = GetRequestRec()->connection->remote_host;
 	hb_retc(remote_host);
}

// client_addr
HB_FUNC( AP_CLIENT_HOSTNAME )
{
  apr_sockaddr_t * addr = GetRequestRec()->connection->client_addr;
 	hb_retc( addr->hostname );
}
HB_FUNC( AP_CLIENT_SERVNAME )
{
  apr_sockaddr_t * addr = GetRequestRec()->connection->client_addr;
 	hb_retc( addr->servname );
}
