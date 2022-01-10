#include "mh_apache.ch"
#define CRLF '<br>'

thread static ts_block := {=>}


function MH_ErrorInfo( oError, cCode, cCodePP )

	local cInfo 	:= ''
	local cStack 	:= ''
	local aTagLine 	:= {}
    local n, aLines, nLine, cLine, nPos, nErrorLine, nL  
	local hError	:= {=>}
	

	
	//	Init hError info 
	
		hError[ 'date' ]		:= DToC( Date() )
		hError[ 'time' ]		:= time()
		hError[ 'description' ]	:= ''
		hError[ 'operation' ]	:= ''
		hError[ 'filename' ]	:= ''
		hError[ 'subsystem' ]	:= ''
		hError[ 'subcode' ]		:= ''
		hError[ 'args' ]		:= {}
		hError[ 'stack' ]		:= {}
		hError[ 'line' ]		:= 0
		hError[ 'type' ] 		:= ''
		hError[ 'block_code' ] 	:= ''
		hError[ 'block_error' ] := ''
		hError[ 'code' ]		:= cCode
		hError[ 'codePP' ]		:= cCodePP
	
	//	Check error from BLOCKS 
	
		if !empty( ts_block )
		
			hError[ 'type' ] 		:= 'block'
			hError[ 'block_code' ] 	:= ts_block[ 'code' ]
			hError[ 'block_error'] 	:= ts_block[ 'error' ]
			
		endif 
			
			
		/*
			//	Pendiente de mirar como encontrar el error dentro del bloque...
			
			? ts_block[ 'code' ] , '<hr>', '<b>Error =></b>', ts_block[ 'error' ] , '<hr>'			
			
			n := hb_At( ts_block[ 'error' ], ts_block[ 'code' ] )

			? n , '<hr>'
		*/
		
		
	//		
		
	hError[ 'description' ]	:= oError:description		
	
    if ! Empty( oError:operation )
		if substr( oError:operation, 1, 5 ) != 'line:'
			hError[ 'operation' ] := oError:operation
		endif
    endif   

    if ! Empty( oError:filename )
		hError[ 'filename' ] := oError:filename 
    endif  
   
	if ! Empty( oError:subsystem )
	
		hError[ 'subsystem' ] := oError:subsystem 
		
		if !empty( oError:subcode ) 
			hError[ 'subcode' ] :=  mh_valtochar(oError:subcode)
		endif
		
	endif  

	//	En el código preprocesado, buscamos tags #line (#includes,#commands,...)

		aLines = hb_ATokens( cCodePP, chr(10) )

		for n = 1 to Len( aLines )   

			cLine := aLines[ n ] 
		  
			if substr( cLine, 1, 5 ) == '#line' 

				nLin := Val(Substr( cLine, 6 ))				

				Aadd( aTagLine, { n, (nLin-n-1) } )
				
			endif 	  

		next 

	//	Buscamos si oError nos da Linea
	
		nL 			:= 0					
		
		if ! Empty( oError:operation )
	  
			nPos := AT(  'line:', oError:operation )

			if nPos > 0 				
				nL := Val( Substr( oError:operation, nPos + 5 ) ) 
			endif	  	  
		  
		endif 
		
	//	Procesamos Offset segun linea error
	
		hError[ 'line' ] := nL
		hError[ 'tag' ] := aTagLine
		
		if nL > 0
		
			hError[ 'line' ] := nL 
		
			//	Xec vectors 	
			//	{ nLine, nOffset }
			//	{ 1, 5 }, { 39, 8 }
			
			for n := 1  to len( aTagLine ) 
				
				if aTagLine[n][1] < nL 
					nOffset 			:= aTagLine[n][2]
					hError[ 'line' ]	:= nL + nOffset 
				endif		
			
			next 
			
		else 
		
		/*
			for n := 1  to len( aTagLine ) 
				
				//if aTagLine[n][1] < nL 
					nOffset 			:= aTagLine[n][2]					
					hError[ 'line' ] := ProcLine( 4 ) + nOffset  //	we need validate
				//endif		
			
			next 		
			*/
			
		endif		

	//	--------------------------------------

	
    if ValType( oError:Args ) == "A"
		hError[ 'args' ] := oError:Args
    endif	
	
    n = 2  
	lReview = .f.
  
    while ! Empty( ProcName( n ) )  
	
		cInfo := "called from: " + If( ! Empty( ProcFile( n ) ), ProcFile( n ) + ", ", "" ) + ;
               ProcName( n ) + ", line: " + ;
               AllTrim( Str( ProcLine( n ) ) ) 
			   
		Aadd( hError[ 'stack' ], cInfo )
		
		n++
		
		if nL == 0 .and. !lReview 
	
			if ProcFile(n) == 'pcode.hrb'
				nL := ProcLine( n )
				
				lReview := .t.
			endif
		
		endif
		
	end
	
	if lReview .and. nL > 0 
		
		hError[ 'line' ] := nL 
		
		for n := 1  to len( aTagLine ) 
			
			if aTagLine[n][1] < nL 
				nOffset 			:= aTagLine[n][2]
				hError[ 'line' ]	:= nL + nOffset 
			endif		
		
		next 	

	endif 

   
retu hError 


function mh_stackblock( cKey, uValue )

	if cKey == NIL
		ts_block := {=>}
	else
		ts_block[ cKey ] := uValue 
	endif
	
retu nil 


function MH_ErrorShow( hError )

	local cHtml := ''
	local aLines, n, cTitle, cInfo, cLine
	
	cHtml += MH_Css()
	cHtml += MH_Html_Header()

	BLOCKS TO cHtml 	
		<div>
			<table>
				<tr>
					<th>Description</th>
					<th>Value</th>			
				</tr>	
	ENDTEXT 

	cHtml += MC_Html_Row( 'Date', hError[ 'date' ] + ' ' + hError[ 'time' ] )	
	cHtml += MC_Html_Row( 'Description', hError[ 'description' ] )	
	
	if !empty( hError[ 'operation' ] )
		cHtml += MC_Html_Row( 'Operation', hError[ 'operation' ] )			
	endif
	
	cHtml += MC_Html_Row( 'Line', hError[ 'line' ] )					
	
	if !empty( hError[ 'filename' ] )
		cHtml += MC_Html_Row( 'Filename', hError[ 'filename' ] )							
	endif 
	
	cHtml += MC_Html_Row( 'System', hError[ 'subsystem' ] + '/' + hError[ 'subcode' ] )							


	if !empty( hError[ 'args' ] )		
	
		cInfo := ''
	
		for n = 1 to Len( hError[ 'args' ] )
			cInfo += "[" + Str( n, 4 ) + "] = " + ValType( hError[ 'args' ][ n ] ) + ;
					"   " + MH_ValToChar( hError[ 'args' ][ n ] ) + ;
					If( ValType( hError[ 'args' ][ n ] ) == "A", " Len: " + ;
					AllTrim( Str( Len( hError[ 'args' ][ n ] ) ) ), "" ) + "<br>"
		next	
	  
		cHtml += MC_Html_Row( 'Arguments', cInfo )							
		
	endif 

	if !empty( hError[ 'stack' ] )
	
		cInfo := ''
	
		for n = 1 to Len( hError[ 'stack' ] )
			cInfo += hError[ 'stack' ][n] + '<br>'
		next	
	  
		cHtml += MC_Html_Row( 'Stack', cInfo )							
		
	endif 
	
	cHtml += '</table></div>'
	
	
	do case
	
		case hError[ 'type' ] == 'block' 
		
			cTitle 	:= 'Code Block'
			
			cInfo 	:= '<div class="mc_block_error"><b>Error => </b><span class="mc_line_error">' + hError[ 'block_error' ] + '</span></div>'
			cInfo 	+= hError[ 'block_code' ] + '<br>'
		
	
		case hError[ 'type' ] == '' 
		
			aLines 	:= hb_ATokens( hError[ 'code' ], chr(10) )

			cTitle 	:= 'Code'
			cInfo 	:= ''
			
			for n = 1 to Len( aLines )

				cLine := aLines[ n ] 
				cLine := hb_HtmlEncode( cLine )
				cLine := StrTran( cLine, chr(9), '&nbsp;&nbsp;&nbsp;' )			  
			  
			  
			  if hError[ 'line' ] > 0 .and. hError[ 'line' ] == n
				cInfo += '<b>' + StrZero( n, 4 ) + ' <span class="mc_line_error">' + cLine + '</span></b>'
			  else			
				cInfo += StrZero( n, 4 ) + ' ' + cLine 
			  endif 
			  
			  cInfo += '<br>'

			next										
			
	endcase		
	
	
	cHtml += '<div class="mc_container_code">'
	cHtml += ' <div class="mc_code_title">' + cTitle + '</div>'
	cHtml += ' <div class="mc_code_source">' + cInfo + '</div>'
	cHtml += '</div>' 
	
	
	
	/*
	BLOCKS TO cHtml PARAMS cTitle, cInfo TAGS <$, $>
		<div>
			<div>
				<$ cTitle $>
			</div>
		
			<div class='mycode'>
				<$ cInfo $>
			</div>
		</div>		
	ENDTEXT 	
	*/
	

	?? cHtml
	

retu nil 

function MC_Html_Row( cDescription, cValue )

	LOCAL cHtml := ''

	BLOCKS TO cHtml PARAMS cDescription, cValue 
		<tr>
			<td class="description" >{{ cDescription }}</td>
			<td class="value">{{ cValue }}</td>
		</tr>
	ENDTEXT
	
retu cHtml 

function MH_Html_Header()

	local cHtml := ''	

	BLOCKS TO cHtml 
		<!DOCTYPE html>
		<html lang="en">
		<head>
			<meta charset="UTF-8">
			<meta name="viewport" content="width=device-width, initial-scale=1">
			<title>ErrorSys</title>										
			<link rel="shortcut icon" type="image/png" href="images/favicon.ico"/>
		</head>		
		
		<div class="title">
			<img class="logo" src="images/modharbour_mini.png"></img>
			<p class="title_error">Error System</p>			
		</div>
		
		<hr>
	ENDTEXT 
	
retu cHtml
		

function MH_Css()

	local cHtml := ''	

	BLOCKS TO cHtml 
		<style>
		
			body { background-color: lightgray; }
			.mc_container_code {
				width: 100%;
				border: 1px solid black;
				box-shadow: 2px 2px 2px black;
				margin-top: 10px;			
			}
			
			.mc_code_title {
				font-family: tahoma;
			    text-align: center;
				background-color: #095fa8;
				padding: 5px;
				color: white;
			}
			
			.mc_code_source {
				padding: 5px;
				font-family: monospace;
				font-size: 12px;
				background-color: #e0e0e0;				
			}
			
			.mc_line_error {
			    background-color: #9b2323;
				color: white;
			}
			
			.mc_block_error {
			    border: 1px solid black;
				padding: 5px;
				margin-bottom: 5px;
			}
			
			table { box-shadow: 2px 2px 2px black; }
			
			table, th, td {
				border-collapse: collapse;
				padding: 5px;
				font-family: tahoma;
			}
			th, td {
				border-bottom: 1px solid #ddd;
			}			
			th {
			  background-color: #095fa8;
			  color: white;
			}	
			
			tr:hover { background-color: yellow; }
			
			.title {
				width:100%;
				height:70px;
			}
			
			.title_error {
				margin-left: 20px;
				float: left;
				margin-top: 20px;
				font-size: 26px;
				font-family: sans-serif;
				font-weight: bold;
			}
			
			.logo {
				float:left;
				width: 100px;
			}
			
			.description {
				font-weight: bold;
				background-color: #8da5b1;
				text-align: right;
			}
			
			.value {				
				background-color: white;
			}			
			
		</style>
	ENDTEXT 
	
retu cHtml


function MH_ErrorShowOk( hError )

	local cHtml := ''
	local n, aLines, cLine 

	cHtml += "<h3>Error System</h3><hr>"
	cHtml += "Description: " + hError[ 'description' ] + "<br>"
	
	if !empty( hError[ 'operation' ] )
		cHtml += "Operation: " + hError[ 'operation' ] + "<br>"
	endif
	
	cHtml += "Line: " + str(hError[ 'line' ]) + "<br>"
	cHtml += "Tag: " + mh_valtochar( hError[ 'tag' ]) + "<br>"
	
	if !empty( hError[ 'filename' ] )
		cHtml += "Filename: " + hError[ 'filename' ] + '<br>' 
	endif 
	
	cHtml += "System: " + hError[ 'subsystem' ] + '/' + hError[ 'subcode' ] + '<br>' 
	
	if !empty( hError[ 'args' ] )
	
		cHtml += '<br><b>Arguments</b></br>'
	
      for n = 1 to Len( hError[ 'args' ] )
          cHtml += "[" + Str( n, 4 ) + "] = " + ValType( hError[ 'args' ][ n ] ) + ;
                   "   " + MH_ValToChar( hError[ 'args' ][ n ] ) + ;
                   If( ValType( hError[ 'args' ][ n ] ) == "A", " Len: " + ;
                   AllTrim( Str( Len( hError[ 'args' ][ n ] ) ) ), "" ) + "<br>"
      next	
	  
	endif 
	
	if !empty( hError[ 'stack' ] )
	
		cHtml += '<br><b>Stack</b></br>'
	
      for n = 1 to Len( hError[ 'stack' ] )
          cHtml += hError[ 'stack' ][n] + '<br>'
      next	
	  
	endif 	
	
	do case
	
		case hError[ 'type' ] == 'block' 
		
			cHtml += '<br><b>Type Block</b><br>'
			
			cHtml += 'Error => ' + hError[ 'block_error' ] + '<br>'
			cHtml += hError[ 'block_code' ] + '<br>'
	
		case hError[ 'type' ] == '' 
		
			aLines 	:= hb_ATokens( hError[ 'code' ], chr(10) )

			cHtml += '<div><code>'
			
			for n = 1 to Len( aLines )

			  cLine := aLines[ n ] 
				cLine := hb_HtmlEncode( cLine )
				cLine := StrTran( cLine, chr(9), '&nbsp;&nbsp;&nbsp;' )			  
			  //cLine := strtran( cLine, '<br>', '&lt;br&gt;' )
			  
			  if hError[ 'line' ] > 0 .and. hError[ 'line' ] == n
				cHtml += '<b>' + StrZero( n, 4 ) + ' <span style="color:red;">' + cLine + '</span></b>'
			  else			
				cHtml += StrZero( n, 4 ) + ' ' + cLine 
			  endif 
			  
			  cHtml += '<br>'

			next				
			
			cHtml += '</code></div>'
		
	endcase	

	?? cHtml 

retu nil