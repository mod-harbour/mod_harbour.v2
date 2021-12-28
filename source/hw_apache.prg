/*
** hw_apache.prg -- Apache harbour module V2
** (c) DHF, 2020-2021
** MIT license
*/


#ifdef __PLATFORM__WINDOWS
  #include "externs.hbx"
#endif

#include "hbthread.ch"
#include "hbclass.ch"

#define CRLF hb_OsNewLine()

THREAD STATIC request_rec

FUNCTION Main()

	AddPPRules()

RETURN NIL

FUNCTION HW_Thread( r )

   LOCAL cFileName

   request_rec := r   

   ErrorBlock( {| oError | AP_RPuts( GetErrorInfo( oError ) ), Break( oError ) } )

   cFileName = AP_FileName()		//	HW_FileName()

   IF File( cFileName )

      IF Lower( Right( cFileName, 4 ) ) == ".hrb"

         hb_hrbDo( hb_hrbLoad( 2, cFileName ), AP_Args() )		//	HW_Args()

      ELSE

         hb_SetEnv( "PRGPATH", ;
            SubStr( cFileName, 1, RAt( "/", cFileName ) + RAt( "\", cFileName ) - 1 ) )
         cCode := MemoRead( cFileName )

         Execute( cCode, AP_Args() )	// HW_Execute( cCode )

      ENDIF

   ELSE

      HW_EXITSTATUS( 404 )

   ENDIF

RETURN

//----------------------------------------------------------------//

FUNCTION GetRequestRec()

RETURN request_rec

//----------------------------------------------------------------//