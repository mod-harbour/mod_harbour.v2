FUNCTION Main()

   LOCAL hData := ap_GetPairs(), cAccessToken := mh_GetCookies( 'access_token' ), hRes := { => }
   LOCAL hCredentials := hb_jsonDecode( hb_MemoRead( hb_GetEnv( 'PRGPATH' ) + "\credentials.json" ) )
   LOCAL cClientId := "", cScopes := "", cRedirectUri := "", cPrompt := ""
   LOCAL hRef := "", cHtml := ""

   IF Empty( hCredentials )
      ?? "Credentials not set"
   ENDIF

   cClientId := hCredentials[ 'web' ][ 'client_id' ]
   cRedirectUri := hCredentials[ 'web' ][ 'redirect_uris' ][ 1 ]   // choose your webapp redirect_uri
   // https://developers.google.com/identity/protocols/oauth2/scopes?hl=es-419
   cScopes += "https://www.googleapis.com/auth/userinfo.email "
   cScopes += "https://www.googleapis.com/auth/userinfo.profile "
/*
   prompt=
   none: Does not display any UI. Only works if the user has previously authorized your application and has an active session.
   consent: Always displays the consent screen, asking the user to grant permissions again.
   select_account: Displays the account selection screen so the user can choose a different account or sign in again.
*/
   cPrompt := "consent"

   cOauthUrl := "https://accounts.google.com/o/oauth2/v2/auth?response_type=code"
   cOauthUrl += "&client_id=" + cClientId
   cOauthUrl += "&redirect_uri=" + cRedirectUri
   cOauthUrl += "&scope=" + cScopes
   cOauthUrl += "&access_type=offline"
   cOauthUrl += "&include_granted_scopes=true"
   cOauthUrl += "&prompt=" + cPrompt

   IF Empty( hData )
      cHtml := hb_MemoRead( hb_GetEnv( 'PRGPATH' ) + '\login.html' )
      cHtml := StrTran( cHtml, "{{href}}", cOauthUrl )
      mh_SetCookie('access_token',"")
      ?? cHtml
      RETURN
   ENDIF

   IF hb_HHasKey( hData, 'code' )

      IF Empty( cAccessToken )
         hRes := hb_jsonDecode( gGetAccessToken( hData[ 'code' ], hCredentials ) )
         cAccessToken := hb_HGetDef( hRes, "access_token", "" )
      ENDIF

      IF Empty( cAccessToken )
         Redirect( "index.prg" )
      ELSE
         mh_SetCookie( 'access_token', cAccessToken ) // Not secure!!!
         Redirect( "user.prg" )
      ENDIF

   ENDIF

RETURN

{% mh_LoadFile( "func.prg" ) %}