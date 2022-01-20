/*
**  preproPHP.prg -- PHP preprocessor
** (c) DHF, 2020-2021
** MIT license
*/

#include "mh_apache.ch"

// ------------------------------------------------------------

FUNCTION MH_PHPprepro( cCode, cStartBlock, cEndBlock )

   LOCAL nStart, nEnd, cBlock
   
   hb_default( @cStartBlock, "<?php" )	//	Tags PHP default
   hb_default( @cEndBlock, "?>" )

   WHILE ( nStart := At( cStartBlock, cCode ) ) != 0 .AND. ;
         ( nEnd := At( cEndBlock, cCode ) ) != 0

      cBlock := mh_PHPcodePost( SubStr( cCode, nStart, ( nEnd + Len( cEndBlock ) - nStart ) ) )

      cCode = SubStr( cCode, 1, nStart - 1 ) + ;
         cBlock + ;
         SubStr( cCode, nEnd + Len( cEndBlock ) )

   END

RETURN cBlock

// ------------------------------------------------------------

FUNCTION mh_PHPcodePost( cCode )

   LOCAL cRet := ""
   LOCAL cPHPfile := AllTrim( Str( hb_RandomInt( 100000 ) ) ) + ".php"
   LOCAL cUrl := AP_GetEnv( "HTTP_HOST" ) + AP_GetEnv( 'MH_PHPTEMP' ) + "/" + cPHPfile
   LOCAL aHeader := {}
   LOCAL ncurlErr

   hb_MemoWrit( cPHPfile := AP_GetEnv( "DOCUMENT_ROOT" ) + AP_GetEnv( 'MH_PHPTEMP' ) + "/" + cPHPfile, cCode )

   IF ! Empty( hCurl  := curl_easy_init() )

      curl_easy_setopt( hCurl, HB_CURLOPT_URL, cUrl )

      curl_easy_setopt( hCurl, HB_CURLOPT_SSL_VERIFYPEER, .F. )
      curl_easy_setopt( hCurl, HB_CURLOPT_SSL_VERIFYHOST, .F. )

      curl_easy_setopt( hCurl, HB_CURLOPT_DOWNLOAD )
      curl_easy_setopt( hCurl, HB_CURLOPT_DL_BUFF_SETUP )

      ncurlErr := curl_easy_perform ( hCurl )

      IF ncurlErr > 0

         cRet := "Curl failed: " + Str( ncurlErr )

      ELSE

         ncode := curl_easy_getinfo( hCurl, HB_CURLINFO_RESPONSE_CODE )
         IF ncurlErr == 0

            cRet := curl_easy_dl_buff_get( hCurl )

         ELSE

            cRet := "Curl error"

         ENDIF

         curl_easy_cleanup( hCurl )

      ENDIF

   ELSE

      cRet := "Curl initialization error"

   ENDIF

   hb_FileDelete( cPHPfile )

RETURN cRet

// ------------------------------------------------------------

FUNCTION mh_PHPfilePost( cUrlFile, hParams )

   LOCAL cRet := ""
   LOCAL aHeader := {}
   LOCAL ncurlErr

   hb_default( @hParams, { => } )

   IF ! Empty( hCurl  := curl_easy_init() )

      IF !Empty( hParams )
         
         AAdd( aHeader, "Content-Type: application/json" )
         curl_easy_setopt( hCurl, HB_CURLOPT_HTTPHEADER, aHeader )
         curl_easy_setopt( hCurl, HB_CURLOPT_POSTFIELDS, hb_jsonEncode( hParams ) )
         
      ENDIF

      curl_easy_setopt( hCurl, HB_CURLOPT_URL, cUrlFile )

      curl_easy_setopt( hCurl, HB_CURLOPT_SSL_VERIFYPEER, .F. )
      curl_easy_setopt( hCurl, HB_CURLOPT_SSL_VERIFYHOST, .F. )

      curl_easy_setopt( hCurl, HB_CURLOPT_DOWNLOAD )
      curl_easy_setopt( hCurl, HB_CURLOPT_DL_BUFF_SETUP )

      ncurlErr := curl_easy_perform ( hCurl )

      IF ncurlErr > 0

         cRet := "Curl failed: " + Str( ncurlErr )

      ELSE

         ncode := curl_easy_getinfo( hCurl, HB_CURLINFO_RESPONSE_CODE )
         IF ncurlErr == 0

            cRet := curl_easy_dl_buff_get( hCurl )

         ELSE

            cRet := "Curl error"

         ENDIF

         curl_easy_cleanup( hCurl )

      ENDIF

   ELSE

      cRet := "Curl initialization error"

   ENDIF

RETURN cRet
