FUNCTION task()

   LOCAL hPost := ap_PostPairs()
   LOCAL oValues := { => }, oData := {=>}, cCode := ""

   ErrorBlock( {| oError | ERROR( Task_GetErrorInfo( oError, @cCode ) ), Break( oError ) } )

   switch hPost[ 'key' ]

   CASE 'task1'
      oDATA[ "error" ] := ''
      oDATA[ "success" ] := .T.
      hb_jsonDecode( hPost[ 'values' ], @oValues )
      oDATA[ "value" ] := task1( oValues )
      EXIT

   CASE 'task2'
      oDATA[ "error" ] := ''
      oDATA[ "success" ] := .T.
      oDATA[ "value" ] := task2(hPost[ 'values' ])
      EXIT

   CASE 'task3'
      oDATA[ "error" ] := ''
      oDATA[ "success" ] := .T.
      oDATA[ "value" ] := task3()
      EXIT

   OTHERWISE
      ERROR( "TASK NO ENCONTRADA" )
   END

   ap_echo( hb_jsonEncode( oDATA, .F. ) )
   
return


function task1( oValues )

return "DATO1: " + oValues['DATO1'] + "<br>" + "DATO2: " + Str(oValues['DATO2'])

function task2( cVar )

   LOCAL hOut := {=>}

   hOut['resultado'] := "TEXTO ENVIADO DESDE EL BACK - " + cVar

return hOut

function task3()

return NOEXISTE


// FUNCIONES BASICAS PARA TODOS LOS PROYECTOS //

// UTILIZADO PARA ERRORES EN TIEMPO DE EJECUCION. Cancela el callback de msgtask
FUNCTION ERROR( ... )

   LOCAL aPar := hb_AParams()
   LOCAL n    := Len( aPar )
   LOCAL cOut := ''

   FOR i = 1 TO n
      cOut += mh_ValtoChar( aPar[ i ] )
   NEXT

   oReturn = { => }
   oReturn[ "success" ] = .F.
   oReturn[ "value" ] = ""
   oReturn[ 'error' ] = mh_ValtoChar( cOut )

   ap_RPuts( hb_jsonEncode( oReturn, .F. ) )
   QUIT

RETURN

// UTILIZADO PARA MENSAJES DIRECTOS AL USUARIO. No cancela el callback de msgtask
FUNCTION MsgInfo( ... )

   LOCAL aPar := hb_AParams()
   LOCAL n    := Len( aPar )
   LOCAL cOut := ''
   LOCAL oReturn := { => }

   FOR i = 1 TO n
      cOut += mh_ValtoChar( aPar[ i ] )
   NEXT

   oReturn[ "success" ] := .F.
   oReturn[ "value" ]   := ""
   oReturn[ "info" ]    := hb_StrToUTF8( cOut )
   oReturn[ 'error' ]   := ""
   ap_RPuts( hb_jsonEncode( oReturn, .F. ) )
   QUIT

RETURN

FUNCTION Task_GetErrorInfo( oError, cCode )

   local n, cInfo := "Error: " + oError:description + "<br>"
   local aLines, nLine

   if ! Empty( oError:operation )
      cInfo += "operation: " + oError:operation + "<br>"
   endif

   if ! Empty( oError:filename )
      cInfo += "filename: " + oError:filename + "<br>"
   endif

   if ValType( oError:Args ) == "A"
      for n = 1 to Len( oError:Args )
          cInfo += "[" + Str( n, 4 ) + "] = " + ValType( oError:Args[ n ] ) + ;
                   "   " + mh_ValToChar( oError:Args[ n ] ) + ;
                   If( ValType( oError:Args[ n ] ) == "A", " Len: " + ;
                   AllTrim( Str( Len( oError:Args[ n ] ) ) ), "" ) + "<br>"
      next
   endif

   n = 2
   while ! Empty( ProcName( n ) )
      cInfo += "called from: " + If( ! Empty( ProcFile( n ) ), ProcFile( n ) + ", ", "" ) + ;
               ProcName( n ) + ", line: " + ;
               AllTrim( Str( ProcLine( n ) ) ) + "<br>"
      n++
   end

   if ! Empty( cCode )
      aLines = hb_ATokens( cCode, Chr( 10 ) )
      cInfo += "<br>Source:<br>" + CRLF
      n = 1
      while( nLine := ProcLine( ++n ) ) == 0
      end
      for n = Max( nLine - 2, 1 ) to Min( nLine + 2, Len( aLines ) )
         cInfo += StrZero( n, 4 ) + If( n == nLine, " =>", ": " ) + ;
                  hb_HtmlEncode( aLines[ n ] ) + "<br>" + CRLF
      next
   endif

RETURN cInfo
