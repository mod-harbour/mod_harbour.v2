/*
**  compatible.prg -- 
**
** Developed by Antonio Linares & Carles Aubia 
** MIT license https://github.com/FiveTechSoft/mod_harbour/blob/master/LICENSE
*/

//----------------------------------------------------------------//

#include 'mh_apache.ch'

#define CRLF '<br>'

//----------------------------------------------------------------//

function AP_PostPairs( lUrlDecode )

   local aHeadersIn		:= ap_HeadersIn()
   local cContentType 	:= lower( HB_HGetDef( aHeadersIn, 'Content-Type', '' ) )
   local hPairs := {=>}
   local aPairs, cPair, uPair, nTable, aTable, cKey, cTag
	
   
   /*	cContentType can be:
		'application/json'
		'application/json;charset=utf-8'
		...
	*/
   
   if hb_at( 'application/json', cContentType ) > 0 
   
		hPairs := hb_jsondecode( ap_Body() )
		
	else 
	  
	   aPairs := hb_ATokens( ap_Body(), "&" )	   
	
	   hb_default( @lUrlDecode, .T. )
	   
	   cTag = If( lUrlDecode, '[]', '%5B%5D' )
	   
	   for each cPair in aPairs
	   
		  if lUrlDecode
			 cPair = hb_urlDecode( cPair )			 
		  endif				

		  if ( uPair := At( "=", cPair ) ) > 0	  
			 cKey = Left( cPair, uPair - 1 )	
			 if ( nTable := At( cTag, cKey ) ) > 0 		
				cKey = Left( cKey, nTable - 1 )			
				aTable = HB_HGetDef( hPairs, cKey, {} ) 				
				AAdd( aTable, SubStr( cPair, uPair + 1 ) )				
				hPairs[ cKey ] = aTable
			 else	 
				hb_HSet( hPairs, cKey, SubStr( cPair, uPair + 1 ) )				
			 endif
		  endif
		  
	   next
   
	endif  
    
return hPairs

//----------------------------------------------------------------//

function AP_GetPairs( lUrlDecode )	

   local cArgs 	:= ap_Args()
   local hPairs := {=>}
   local cPair, uPair, nPos, cKey, cTag
	
   hb_default( @lUrlDecode, .T. )
   cTag = If( lUrlDecode, '[]', '%5B%5D' )
   
   for each cPair in hb_ATokens( cArgs, "&" )

		if !empty( cPair )

		  if lUrlDecode
			 cPair = hb_urldecode( cPair )
		  endif		 
		  
		  if ( uPair := At( "=", cPair ) ) > 0	  
			 cKey = Left( cPair, uPair - 1 )	
			 if ( nTable := At( cTag, cKey ) ) > 0 		
				cKey = Left( cKey, nTable - 1 )			
				aTable = HB_HGetDef( hPairs, cKey, {} ) 				
				AAdd( aTable, SubStr( cPair, uPair + 1 ) )				
				hPairs[ cKey ] = aTable
			 else						
				hb_HSet( hPairs, cKey, SubStr( cPair, uPair + 1 ) )
			 endif
		  endif	
	  
	    endif
   next


return hPairs

//----------------------------------------------------------------//

function MH_PathUrl()

   local cPath := ap_GetEnv( 'SCRIPT_NAME' )   
   local n     := RAt( '/', cPath )
        
return Substr( cPath, 1, n - 1 )

//----------------------------------------------------------------//

function MH_PathBase( cDirFile )

   local cPath := hb_GetEnv( "PRGPATH" ) 
    
   hb_default( @cDirFile, '' )
    
   cPath += cDirFile
    
   if "Linux" $ OS()    
      cPath = StrTran( cPath, '\', '/' )     
   endif
   
return cPath

//----------------------------------------------------------------//

function MH_Include( cFile )

   local cPath := ap_GetEnv( "DOCUMENT_ROOT" ) 

   hb_default( @cFile, '' )
   cFile = cPath + cFile   
   
   if "Linux" $ OS()
      cFile = StrTran( cFile, '\', '/' )     
   endif   
    
   if File( cFile )
      return MemoRead( cFile )
   endif
   
return ""

//----------------------------------------------------------------//

function MH_GetErrorInfo( oError, cCode )

	local cInfo := ''
    local n, aLines, nLine   

	cInfo += "<h3>Error System</h3><hr>"
	cInfo += "Error: " + oError:description + "<br>"
	
   if ! Empty( oError:operation )
      cInfo += "operation: " + oError:operation + "<br>"
   endif   

   if ! Empty( oError:filename )
      cInfo += "filename: " + oError:filename + "<br>"
   endif  

	
   if ValType( oError:Args ) == "A"
      for n = 1 to Len( oError:Args )
          cInfo += "[" + Str( n, 4 ) + "] = " + ValType( oError:Args[ n ] ) + ;
                   "   " + MH_ValToChar( oError:Args[ n ] ) + ;
                   If( ValType( oError:Args[ n ] ) == "A", " Len: " + ;
                   AllTrim( Str( Len( oError:Args[ n ] ) ) ), "" ) + "<br>"
      next
   endif	
	
   n = 2
   
   cInfo += CRLF 
   
   while ! Empty( ProcName( n ) )  
      cInfo += "called from: " + If( ! Empty( ProcFile( n ) ), ProcFile( n ) + ", ", "" ) + ;
               ProcName( n ) + ", line: " + ;
               AllTrim( Str( ProcLine( n ) ) ) + "<br>"
      n++
   end
   
   /*
   if ! Empty( cCode )

      aLines = hb_ATokens( cCode, Chr( 10 ) )

      cInfo += "<br>Source:<br>" + CRLF
      n = 1
	  
      while( nLine := ProcLine( ++n ) ) == 0
      end  	  
	 
      for n = Max( nLine - 2, 1 ) to Min( nLine + 2, Len( aLines ) )
         cInfo += StrZero( n, 4 ) + If( n == nLine, " =>", ": " ) + ;
                  hb_HtmlEncode( aLines[ n ] ) + CRLF
      next
   endif  
   */

	?? cInfo  

return nil

//----------------------------------------------------------------//

function MH_ObjToChar( o )

   local hObj := {=>}, aDatas := __objGetMsgList( o, .T. )
   local hPairs := {=>}, aParents := __ClsGetAncestors( o:ClassH )

   AEval( aParents, { | h, n | aParents[ n ] := __ClassName( h ) } ) 

   hObj[ "CLASS" ] = o:ClassName()
   hObj[ "FROM" ]  = aParents 

   AEval( aDatas, { | cData | hPairs[ cData ] := __ObjSendMsg( o, cData ) } )
   hObj[ "DATAs" ]   = hPairs
   hObj[ "METHODs" ] = __objGetMsgList( o, .F. )

return MH_ValToChar( hObj )

//----------------------------------------------------------------//

function MH_ValToChar( u )

   local cType := ValType( u )
   local cResult

   do case
      case cType == "C" .or. cType == "M"
           cResult = u

      case cType == "D"
           cResult = DToC( u )

      case cType == "L"
           cResult = If( u, ".T.", ".F." )

      case cType == "N"
           cResult = AllTrim( Str( u ) )

      case cType == "A"
           cResult = hb_ValToExp( u )

      case cType == "O"
           cResult = MH_ObjToChar( u )

      case cType == "P"
           cResult = "(P)" 

      case cType == "S"
           cResult = "(Symbol)" 
 
      case cType == "H"
           cResult = StrTran( StrTran( hb_JsonEncode( u, .T. ), CRLF, "<br>" ), " ", "&nbsp;" )
           if Left( cResult, 2 ) == "{}"
              cResult = StrTran( cResult, "{}", "{=>}" )
           endif   

      case cType == "U"
           cResult = "nil"

      otherwise
           cResult = "type not supported yet in function MH_ValToChar()"
   endcase

return cResult   

//----------------------------------------------------------------//
//	Check la de Diego -> pool.txt

function hb_HtmlEncode( cString )
   
   local cChar, cResult := "" 

   for each cChar in cString
      do case
      case cChar == "<"
            cChar = "&lt;"

      case cChar == '>'
            cChar = "&gt;"     
            
      case cChar == "&"
            cChar = "&amp;"     

      case cChar == '"'
            cChar = "&quot;"    
            
      case cChar == " "
            cChar = "&nbsp;"               
      endcase
      cResult += cChar 
   next
    
return cResult   
