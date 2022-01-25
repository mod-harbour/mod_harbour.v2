/*
**  cookies.prg -- cookies management
**
** Developed by Carles Aubia carles9000@gmail.com
** MIT license https://github.com/FiveTechSoft/mod_harbour/blob/master/LICENSE
*/

//----------------------------------------------------------------//

function MH_GetCookies( cKey )

   local cCookies 		:= ap_GetEnv( "HTTP_COOKIE" )
   local aCookies 		:= hb_aTokens( cCookies, ";" )
   local hHeadersOut 	:= ap_HeadersOut(), cCookieHeader
   local cCookie, hCookies := {=>}
   local cHKey, uValue 

   if( hb_HHasKey( hHeadersOut, "Set-Cookie" ) )
      cCookieHeader := hHeadersOut[ "Set-Cookie" ]
      cCookieHeader := Left( cCookieHeader, At( ';', cCookieHeader )-1 )
      AAdd( aCookies, cCookieHeader )
   endif
   
   for each cCookie in aCookies
	  cHKey 	:= LTrim( SubStr( cCookie, 1, At( "=", cCookie ) - 1 ) )
	  uValue 	:= SubStr( cCookie, At( "=", cCookie ) + 1 ) 
	  
	  if !empty( cHKey )
		hb_HSet( hCookies, cHKey, uValue )
	  endif
               
   next   
   
   hb_HCaseMatch( hCookies, .f. )
   

return if( valtype( cKey ) == 'C', HB_HGetDef( hCookies, cKey, '' ), hCookies )

//----------------------------------------------------------------//

function MH_SetCookie( cName, cValue, nSecs, cPath, cDomain, lHttps, lOnlyHttp ) 

   local cCookie := ''
	
   // check parameters
   hb_default( @cName, '' )
   hb_default( @cValue, '' )
   hb_default( @nSecs, 3600 )   // Session will expire in Seconds 60 * 60 = 3600
   hb_default( @cPath, '/' )
   hb_default( @cDomain	, '' )
   hb_default( @lHttps, .F. )
   hb_default( @lOnlyHttp, .F. )	
	
   // we build the cookie
   cCookie += cName + '=' + cValue + ';'
   cCookie += 'expires=' + MH_CookieExpires( nSecs ) + ';'
   cCookie += 'path=' + cPath + ';'
   
   if ! Empty( cDomain )
      cCookie += 'domain=' + cDomain + ';'
   endif
		
   // pending logical values for https y OnlyHttp

   // we send the cookie
   ap_HeadersOutSet( "Set-Cookie", cCookie )

return nil

//----------------------------------------------------------------//
// CookieExpire( nSecs ) builds the time format for the cookie
// Using this model: 'Sun, 09 Jun 2019 16:14:00'

static function MH_CookieExpires( nSecs )

   local tNow := hb_datetime()	
   local tExpire   // TimeStampp 
   local cExpire   // TimeStamp to String
	
   hb_default( @nSecs, 60 ) // 60 seconds for this test
   
   tExpire = hb_ntot( ( hb_tton( tNow ) * 86400 - hb_utcoffset() + nSecs ) / 86400 )

   cExpire = cdow( tExpire ) + ', ' 
	     cExpire += AllTrim( Str( Day( hb_TtoD( tExpire ) ) ) ) + ;
	     ' ' + cMonth( tExpire ) + ' ' + AllTrim( Str( Year( hb_TtoD( tExpire ) ) ) ) + ' ' 
   cExpire += AllTrim( Str( hb_Hour( tExpire ) ) ) + ':' + AllTrim( Str( hb_Minute( tExpire ) ) ) + ;
              ':' + AllTrim( Str( hb_Sec( tExpire ) ) )

return cExpire

//----------------------------------------------------------------//
