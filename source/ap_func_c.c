/*
**  ap_func_c.c -- Apache API in wrappers
**
*/

#include <http_protocol.h>
#include <apr_pools.h>
#include <util_cookies.h>
#include <hbapi.h>
#include <hbapiitm.h>

request_rec * GetRequestRec( void );

//----------------------------------------------------------------//

const char * ap_headers_in_key( int iKey )
{
   const apr_array_header_t * fields = apr_table_elts( GetRequestRec()->headers_in );
   apr_table_entry_t * e = ( apr_table_entry_t * ) fields->elts;

   if( iKey >= 0 && iKey < fields->nelts )
      return e[ iKey ].key;
   else
      return "";
}

//----------------------------------------------------------------//

HB_FUNC( AP_HEADERSINKEY )
{
   hb_retc( ap_headers_in_key( hb_parnl( 1 ) ) );
}

//----------------------------------------------------------------//

const char * ap_headers_in_val( int iKey )
{
   const apr_array_header_t * fields = apr_table_elts( GetRequestRec()->headers_in );
   apr_table_entry_t * e = ( apr_table_entry_t * ) fields->elts;

   if( iKey >= 0 && iKey < fields->nelts )
      return e[ iKey ].val;
   else
      return "";
}

//----------------------------------------------------------------//

const char * ap_headers_out_key( int iKey )
{
   const apr_array_header_t * fields = apr_table_elts( GetRequestRec()->headers_out );
   apr_table_entry_t * e = ( apr_table_entry_t * ) fields->elts;

   if( iKey >= 0 && iKey < fields->nelts )
      return e[ iKey ].key;
   else
      return "";
}

//----------------------------------------------------------------//

const char * ap_headers_out_val( int iKey )
{
   const apr_array_header_t * fields = apr_table_elts( GetRequestRec()->headers_out );
   apr_table_entry_t * e = ( apr_table_entry_t * ) fields->elts;

   if( iKey >= 0 && iKey < fields->nelts )
      return e[ iKey ].val;
   else
      return "";
}

//----------------------------------------------------------------//

HB_FUNC( AP_HEADERSIN )
{
   PHB_ITEM hHeadersIn = hb_hashNew( NULL ); 
   int iKeys = apr_table_elts( GetRequestRec()->headers_in )->nelts;

   if( iKeys > 0 )
   {
      int iKey;
      PHB_ITEM pKey = hb_itemNew( NULL );
      PHB_ITEM pValue = hb_itemNew( NULL );   

      hb_hashPreallocate( hHeadersIn, iKeys );
   
      for( iKey = 0; iKey < iKeys; iKey++ )
      {
         hb_itemPutCConst( pKey,   ap_headers_in_key( iKey ) );
         hb_itemPutCConst( pValue, ap_headers_in_val( iKey ) );
         hb_hashAdd( hHeadersIn, pKey, pValue );
      }
      
      hb_itemRelease( pKey );
      hb_itemRelease( pValue );
   }

   hb_itemReturnRelease( hHeadersIn );
}

//----------------------------------------------------------------//

HB_FUNC( AP_HEADERSOUT )
{
   PHB_ITEM hHeadersOut = hb_hashNew( NULL ); 
   int iKeys = apr_table_elts( GetRequestRec()->headers_out )->nelts;

   if( iKeys > 0 )
   {
      int iKey;
      PHB_ITEM pKey = hb_itemNew( NULL );
      PHB_ITEM pValue = hb_itemNew( NULL );   

      hb_hashPreallocate( hHeadersOut, iKeys );
   
      for( iKey = 0; iKey < iKeys; iKey++ )
      {
         hb_itemPutCConst( pKey,   ap_headers_out_key( iKey ) );
         hb_itemPutCConst( pValue, ap_headers_out_val( iKey ) );
         hb_hashAdd( hHeadersOut, pKey, pValue );
      }
      
      hb_itemRelease( pKey );
      hb_itemRelease( pValue );
   }  
   
   hb_itemReturnRelease( hHeadersOut );
}

//----------------------------------------------------------------//

HB_FUNC( AP_ARGS )
{
   hb_retc( GetRequestRec()->args ); 
}

//----------------------------------------------------------------//


HB_FUNC( AP_GETBODY )
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

HB_FUNC( AP_FILENAME )
{
   hb_retc( GetRequestRec()->filename );
}

//----------------------------------------------------------------//

HB_FUNC( AP_GETENV )
{
   hb_retc( apr_table_get( GetRequestRec()->subprocess_env, hb_parc( 1 ) ) );
}   

//----------------------------------------------------------------//

HB_FUNC( AP_HEADERSINVAL )
{
   hb_retc( ap_headers_in_val( hb_parnl( 1 ) ) );
}

//----------------------------------------------------------------//

HB_FUNC( AP_METHOD )
{
   hb_retc( GetRequestRec()->method );
}

//----------------------------------------------------------------//

HB_FUNC( AP_USERIP )
{
   hb_retc( GetRequestRec()->useragent_ip );
}

//----------------------------------------------------------------//

HB_FUNC( AP_HEADERSOUTKEY )
{
   hb_retc( ap_headers_out_key( hb_parnl( 1 ) ) );
}

//----------------------------------------------------------------//

HB_FUNC( AP_HEADERSOUTVAL )
{
   hb_retc( ap_headers_out_val( hb_parnl( 1 ) ) );
}

//----------------------------------------------------------------//

HB_FUNC( AP_HEADERSOUTSET )
{
   apr_table_add( GetRequestRec()->headers_out, hb_parc( 1 ), hb_parc( 2 ) );
}

//----------------------------------------------------------------//

HB_FUNC( AP_RWRITE )
{
   hb_retni( ap_rwrite( ( void * ) hb_parc( 1 ), ( int ) hb_parclen( 1 ), GetRequestRec() ) );
}

//----------------------------------------------------------------//

HB_FUNC( AP_SETCONTENTTYPE ) // szContentType
{
   request_rec * r = GetRequestRec();
   char * szType = ( char * ) apr_pcalloc( r->pool, hb_parclen( 1 ) + 1 );
   
   strcpy( szType, hb_parc( 1 ) );   
   r->content_type = szType;
}

//----------------------------------------------------------------//

HB_FUNC( AP_HEADERSINCOUNT )
{
   hb_retnl( apr_table_elts( GetRequestRec()->headers_in )->nelts );
}

//----------------------------------------------------------------//

HB_FUNC( AP_HEADERSOUTCOUNT )
{
   hb_retnl( apr_table_elts( GetRequestRec()->headers_out )->nelts );
}

//----------------------------------------------------------------//
HB_FUNC( AP_COOKIE_REMOVE )
{
   request_rec * r = GetRequestRec();
   ap_cookie_remove( r, hb_parc( 1 ),  NULL, r->headers_out, r->err_headers_out, NULL );
}

//----------------------------------------------------------------//

HB_FUNC( AP_COOKIE_READ )
{
   const char *val = NULL;
   apr_status_t rs;
   request_rec * r = GetRequestRec();
   rs = ap_cookie_read( r, hb_parc( 1 ), &val, hb_parldef( 2, 0 ) );
   if ( APR_SUCCESS != rs ) 
      hb_retc( val );
   else 
      hb_retl( 0 );
}

//----------------------------------------------------------------//

HB_FUNC( AP_COOKIE_WRITE )
{
   request_rec * r = GetRequestRec();
   ap_cookie_write( r, hb_parc( 1 ), hb_parc( 2 ), NULL, 60, r->headers_out, r->err_headers_out, NULL );
}

//----------------------------------------------------------------//

HB_FUNC( AP_COOKIE_CHECK_STRING )
{
   apr_status_t rs;
   rs = ap_cookie_check_string( hb_parc( 1 ) );
   if ( APR_SUCCESS != rs ) 
      hb_retl( 0 );
   else 
      hb_retl( 1 );
}