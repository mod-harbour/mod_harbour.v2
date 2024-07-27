#include "hbcurl.ch"

FUNCTION Redirect( cUrl )

   ?? '<script>'
   ??  "window.location.replace( '" + cUrl + "'); "
   ??  '</script>'

RETURN

FUNCTION gGetAccessToken( cCode, hCredentials )

   LOCAL aHeader := {}, curl, ncurlErr, ncode, cJsonRes

   LOCAL sUrl := "https://oauth2.googleapis.com/token"

   LOCAL cPostData := ""

   cPostData += "code=" + cCode + "&"
   cPostData += "client_id=" + hCredentials[ 'web' ][ 'client_id' ] + "&"
   cPostData += "client_secret=" + hCredentials[ 'web' ][ 'client_secret' ] + "&"
   cPostData += "redirect_uri=" + hCredentials[ 'web' ][ 'redirect_uris' ][ 1 ] + "&"
   cPostData += "grant_type=authorization_code"

   AAdd( aHeader, "Content-Type: application/x-www-form-urlencoded" )

   IF ! Empty( curl := curl_easy_init() )

      curl_easy_setopt( curl, HB_CURLOPT_HTTPHEADER, aHeader )
      curl_easy_setopt( curl, HB_CURLOPT_URL, sUrl )
      curl_easy_setopt( curl, HB_CURLOPT_SSL_VERIFYPEER, .F. )
      curl_easy_setopt( curl, HB_CURLOPT_SSL_VERIFYHOST, .F. )
      curl_easy_setopt( curl, HB_CURLOPT_DOWNLOAD )
      curl_easy_setopt( curl, HB_CURLOPT_DL_BUFF_SETUP )
      curl_easy_setopt( curl, HB_CURLOPT_POSTFIELDS, cPostData )
      curl_easy_setopt( curl, HB_CURLOPT_TIMEOUT, 10 )
      curl_easy_setopt( curl, HB_CURLOPT_VERBOSE, .T. )

      ncurlErr := curl_easy_perform ( curl )

      ncode := curl_easy_getinfo( curl, HB_CURLINFO_RESPONSE_CODE )
      IF ncurlErr == 0
         cJsonRes := curl_easy_dl_buff_get( curl )
      ELSE
         cJsonRes := "Curl error" + Str( ncurlErr )
      ENDIF

      curl_easy_cleanup( curl )

   ENDIF

RETURN cJsonRes

FUNCTION gGetUserData( cAccessToken )

   LOCAL aHeader := {}, curl, ncurlErr, ncode, cJsonRes

   LOCAL sUrl := "https://www.googleapis.com/oauth2/v2/userinfo"

   AAdd( aHeader, "Authorization: Bearer " + AllTrim( cAccessToken ) )

   IF ! Empty( curl := curl_easy_init() )

      curl_easy_setopt( curl, HB_CURLOPT_HTTPHEADER, aHeader )
      curl_easy_setopt( curl, HB_CURLOPT_URL, sUrl )
      curl_easy_setopt( curl, HB_CURLOPT_SSL_VERIFYPEER, .F. )
      curl_easy_setopt( curl, HB_CURLOPT_SSL_VERIFYHOST, .F. )
      curl_easy_setopt( curl, HB_CURLOPT_DOWNLOAD )
      curl_easy_setopt( curl, HB_CURLOPT_DL_BUFF_SETUP )
      curl_easy_setopt( curl, HB_CURLOPT_TIMEOUT, 10 )
      curl_easy_setopt( curl, HB_CURLOPT_VERBOSE, .T. )

      ncurlErr := curl_easy_perform ( curl )
      ncode := curl_easy_getinfo( curl, HB_CURLINFO_RESPONSE_CODE )

      IF ncurlErr == 0
         cJsonRes := curl_easy_dl_buff_get( curl )
      ELSE
         cJsonRes := "Curl error" + Str( ncurlErr )
      ENDIF

      curl_easy_cleanup( curl )

   ENDIF

RETURN cJsonRes
