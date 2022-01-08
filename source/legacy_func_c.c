/*
**  compatible_c.c --
**
** (c) FiveTech Software SL, 2019-2020
** Developed by Antonio Linares alinares@fivetechsoft.com
** MIT license https://github.com/FiveTechSoft/mod_harbour/blob/master/LICENSE
*/

#include <http_protocol.h>
#include <apr_pools.h>
#include <hbapi.h>
#include <hbapierr.h>
#include <hbapiitm.h>
#include <hbvm.h>

request_rec * GetRequestRec( void );

//----------------------------------------------------------------//

int mh_rputs( const char * szText )
{
   return ap_rputs( szText, GetRequestRec() );
}

//----------------------------------------------------------------//

int mh_rputslen( const char * szText, HB_SIZE iLength )
{
   return ap_rwrite( szText, iLength, GetRequestRec() );
}

//----------------------------------------------------------------//

HB_FUNC( AP_RPUTS )
{
   int iParams = hb_pcount(), iParam;

   for( iParam = 1; iParam <= iParams; iParam++ )
   {
      PHB_ITEM pItem = hb_param( iParam, HB_IT_ANY );

      if( HB_ISOBJECT( iParam ) )
      {
         hb_vmPushSymbol( hb_dynsymGetSymbol( "MH_OBJTOCHAR" ) );
         hb_vmPushNil();
         hb_vmPush( pItem );
         hb_vmFunction( 1 );
         mh_rputslen( hb_parc( -1 ), hb_parclen( -1 ) );
      }
      else if( HB_ISHASH( iParam ) || HB_ISARRAY( iParam ) )
      {
         hb_vmPushSymbol( hb_dynsymGetSymbol( "MH_VALTOCHAR" ) );
         hb_vmPushNil();
         hb_vmPush( pItem );
         hb_vmFunction( 1 );
         mh_rputslen( hb_parc( -1 ), hb_parclen( -1 ) );
      }
      else
      {
         HB_SIZE nLen;
         HB_BOOL bFreeReq;
         char * buffer = hb_itemString( pItem, &nLen, &bFreeReq );

         mh_rputslen( buffer, nLen );
         mh_rputs( " " ); 

         if( bFreeReq )
            hb_xfree( buffer );
      }      
   }

   hb_ret();     
}

//----------------------------------------------------------------//

HB_FUNC( MH_MODBUILDDATE )
{
   char * pszDate;
   
   pszDate = ( char * ) hb_xgrab( 64 );
   hb_snprintf( pszDate, 64, "%s %s", __DATE__, __TIME__ );
   
   hb_retc_buffer( pszDate );
}

//----------------------------------------------------------------//

HB_FUNC( PTRTOSTR )
{
   #ifdef HB_ARCH_32BIT
      const char * * pStrs = ( const char * * ) hb_parnl( 1 );   
   #else
      const char * * pStrs = ( const char * * ) hb_parnll( 1 );   
   #endif

   hb_retc( * ( pStrs + hb_parnl( 2 ) ) );
}

//----------------------------------------------------------------//

HB_FUNC( PTRTOUI )
{
   #ifdef HB_ARCH_32BIT
      unsigned int * pNums = ( unsigned int * ) hb_parnl( 1 );   
   #else
      unsigned int * pNums = ( unsigned int * ) hb_parnll( 1 );   
   #endif

   hb_retnl( * ( pNums + hb_parnl( 2 ) ) );
}

//----------------------------------------------------------------//
/*
**  url.c -- Giancarlo Nicolai's UrlDecode harbour module
*/
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

