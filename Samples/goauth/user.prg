#include "hbcurl.ch"

FUNCTION Main()

   LOCAL cAccessToken := mh_GetCookies( 'access_token' ), hUser := { => }

   IF Empty( cAccessToken )
      mh_ExitStatus( 302 )
      AP_HeadersOutSet( "Location", "index.prg" )
      RETURN
   ENDIF

   hUser := hb_jsonDecode( gGetUserData( cAccessToken ) ) 
   // Validate token
   IF hb_HHasKey( hUser, "id" )

      ? "<html>"
      ? "Token: ", cAccessToken
      ? "User Data: ", hUser
      ? '<a href="index.prg">Logout!</a>'
      ? "</html>"

   ELSE
      mh_SetCookie( 'access_token', "" )
      Redirect( "index.prg" )
   ENDIF

RETURN

{% mh_LoadFile( "func.prg" ) %}
