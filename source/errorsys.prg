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
		
			hError[ 'type' ] 		:= ts_block[ 'type' ]	// 'block'
			
			do case	
				case hError[ 'type' ] == 'block'
					hError[ 'block_code' ] 	:= ts_block[ 'code' ]
					hError[ 'block_error'] 	:= ts_block[ 'error' ]
				
				case hError[ 'type' ] == 'initprocess'
					hError[ 'filename' ]	:= ts_block[ 'filename' ]
			endcase
			
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
	
	
	if !empty( hError[ 'line' ] )
		cHtml += MC_Html_Row( 'Line', hError[ 'line' ] )					
	endif
	
	if !empty( hError[ 'filename' ] )
		cHtml += MC_Html_Row( 'Filename', hError[ 'filename' ] )							
	endif 
	
	cHtml += MC_Html_Row( 'System', hError[ 'subsystem' ] + if( !empty(hError[ 'subcode' ]), '/' + hError[ 'subcode' ], '') )							


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
			aLines 	:= hb_ATokens( hError[ 'block_code' ], chr(10) )
	
		case hError[ 'type' ] == '' 		

			cTitle 	:= 'Code'
			cInfo 	:= ''
			aLines 	:= hb_ATokens( hError[ 'code' ], chr(10) )
			
		case hError[ 'type' ] == 'initprocess' 					

			cTitle 	:= 'InitProcess'
			cInfo 	:= '<div class="mc_block_error"><b>Filename => </b><span class="mc_line_error">' + hError[ 'filename' ] + '</span></div>'
			aLines 	:= {}		
			
	endcase	

	
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
			<link rel="shortcut icon" type="image/png" href="{{ mh_favicon() }}"/>
		</head>		
		
		<div class="title">
			<img class="logo" src="{{ mh_logo() }}"></img>
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

function MH_Logo()
retu 'https://i.postimg.cc/GmJy078K/modharbour-mini.png'
//retu 'data:image/png;base64,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'

function MH_FavIcon()
retu 'https://i.postimg.cc/g2HWb5Vg/favicon.png'
//retu 'data:image/jpg;base64,AAABAAEAQEAAAAEAIAAoQgAAFgAAACgAAABAAAAAgAAAAAEAIAAAAAAAAEAAAMMOAADDDgAAAAAAAAAAAAD////////////////////////////////////////////////////////////////a0Mj/xrWl///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////59/b/n3ld/4NOJ//Vx7v////+/////////////////////////////v7+//z7+//7+fj/+fj3//n49v/5+Pf/+vn4//39/P//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////xK+f/4E9Ef98Ngn/hEgf/6uIb//Gr53/xq6b/7+jkP+4mIL/sI93/6iKcf+kiW3/po94/66bif+2ppf/w7et/9DLyP/h3uH/7evx/+7t9P/t7PT/7ez1/+7t9f/w7/X/9/f6//z8/f////7/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////4NbP/4ZPKf96NAb/fDUG/341B/98Ow3/hE0h/41fO/+YcFT/oYBv/6mQi/+olZ7/oZGr/5CDrv+GerT/eGyz/2per/9hVK//V0mu/00+qv9IOKj/SDem/0g3p/9JOan/T0Co/1xPrv9nXLP/e3G7/5aOyv+0rtf/1tTn//Dv9v//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////7Ofj/5dtT/+DRhz/kWA7/553Xf+miH7/pZGc/5qLr/+HfLX/cGSz/1hJsf9CM6r/NCKj/ysXnv8iDZ3/Hgie/x4Hm/8dBpr/HAWa/x0Gm/8eB5z/Hgib/yEKm/8iDJv/Iw2c/yMOmv8iDJr/HQmb/xsHmv8dCJz/Ig2b/zAem/9KPKn/fHK9/8G83//8/P7//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////8i+vP+ijZD/mIeo/4N3tP9mWbL/STis/zUiov8lEZz/HQia/xsGmf8cBpv/Hwmc/yQQnv8tG6L/OCmk/0g6qf9YS67/Z1u1/3Rqu/99cr7/ioDC/5WMw/+Zj8H/nJO+/6GXvP+hl7r/oJW7/5qPu/+Vi73/ioC8/3lutv9oXbT/UUSq/zkpov86K57/ysff/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////f3+/6mj0P9VRqz/Oiii/yYSnf8aBpz/Gwaa/x8Lmv8oFp7/OSil/04/rv9mW7n/fHK9/5WMw/+pnsL/tKi9/7epsf+5p6X/t6CT/66Sfv+qiHH/pH1h/51xUP+YaUT/kF85/45bM/+NWS//ilgu/4tYMP+LWTL/jV03/5FjQP+WbUz/nnpg/6WHd/+qlJX/nY+q/83J2////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////f3+/6ae0P8tGZv/IAub/ywaof9CMqn/YFOz/31zu/+Xjb7/q5+5/7alrf+4opv/r5J+/6Z/Yv+Za0r/jlky/4RJH/9+PhL/eDcL/3g2Cf96OQv/fD8T/4FIIf+EUi3/j2A+/5xvUP+me2D/q4Vs/6+Od/+1ln//uZ2I/7qeiv+5m4b/tJN6/6uGbP+geFr/kWZE/4ldPP/Sxbv//////////////////////////////////////////////////////////////////f39/////////////////////////////////////////////////////////////v7//7i01/9kWK7/dGiz/5OHtv+qnLD/s52d/62Qfv+ke1z/lmM+/4dNIv+BPhH/ejYI/3g0Bv97OQv/gEQZ/4lSLf+WZ0b/pH1i/7KVf//Cqpj/0L6w/97Tyv/q4tz/8Ozo//b08v/7+/r//v7+/////////////////////////////////////////////f38//bz8f/m39n/8u/s///////////////////////+/v7//v7+///////////////////////////////////////////////////////////////////////////////////////8+/r/8u7q/9vRyv+um5j/o4V1/5pwUf+QWS//gEMY/3o3C/90NAb/fTcL/4JDG/+NVzL/nHBQ/6uLdP+/p5f/1MS4/+Tb0//v6ub/+Pb0//7+/f//////7/Dw/729vv////////////////////////////7+/v//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////+/r6/9THvP+1moT/nnZW/49YMf+AQhf/fDcL/3w1Cf99PRL/hU4o/5RmRf+lgmb/vKGL/9PCtv/k29P/8e3q//v6+P///////////////////////////////////////////8nJyf+Ghob//////////////////////+fn5//Hx8b//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////+ji3f+DTyv/dzUI/31AF/+MVTH/m29P/66Qef/FsKH/287E/+vm4f/49vX/8/Ds/8yxkf/s3s///Pv6///////////////////////////////////////////////////////ExMT/hYWF//////////////////////+3t7f/lJSU///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////u6ub/vaWT/824qf/g1cz/8Ozp//v59/////////////////////////////z6+f+0iFf/pmYe/7iKVf/OsY//4c24/+rbyf/p2sj/2cOs/9bDrf/+/v7/////////////////w8PD/4aGhf//////////////////////srGx/4+Pj/////////////////////////////////////////////////////////////v7+//t7e3/8fHx/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////+Taz//j1cb//v7/////////////qJqN/24+C/+fWQn/qF4I/6hiD/+kZBz/qWQY/6dcCv/EmGf//////////////////////8LCwv+Hhob//////////////////////7S0tP+NjY3////////////i4uL/vLy8//Ly8v////////////////////////////////++vr7/RERE/0BAQP+Pjo7/9/f3//7+/v/Y2Nj/4uHh//////////////////z8/P/6+vr////////////////////////////v7+//4N/f///////////////////////////////////////o28z/rHQ0/8aiev/t4dP//////7/Awv8YEhD/PCEK/3NDEP9+SAv/ZzsL/6BbCv+mXAP/x59u///////////////////////BwcH/iIeH//////////////////////+3trb/h4eG///////x8fH/hYWE/zQzM/9zc3P/xcXF/9bW1v///////////76+vv/Dw8P/5OPj/8jHx/+kpKP/PDw8/8DAwP/Ozs7/T09P/z09Pf/W1tb///////r6+v+Kior/Wlpa/8fHx/+tra3/3d3d///////i4uL/aGho/3V1df//////////////////////////////////////+vj2/7qGTf+mWgP/qm0m/8Secf/LuaT/Niok/wgCAf8QBgP/EggE/zMaBv+gWQr/p10D/8qjdv//////////////////////wMDA/4qJif//////////////////////ubm5/4ODg///////yMjI/93d3f/Y19f/SkpK/05OTf9NTUz/7u7u/+7u7v+2trX/7e3t/6CgoP/NzMz//////7Gxsf+vr6//t7e3/+fn5/97e3v/fX19/9TU1P/AwMD/s7Oz/2pqav82Njb/SEhI/z09Pf/Ly8v/wsLC/9PT0//v7+/////////////////////////////////////////////QspD/pl0H/6deB/+nXAb/qGIR/5BUE/90Qg7/bDwJ/3E/C/9pPA7/nlgK/6ddBv/Mp3z//////////////////////729vf+Li4v//////////////////////728vP+BgYH//////5OSkv/CwsL//////8nJyf/d3d3/WVlZ/4KCgv/W1tb/+vn5//////+ampr/fn5+///////Ozs3/zMzM/3Nzc//v7+//09PT/1JSUf9HR0f/QEA//+3t7f/y8vL/Xl5e/8bGxv97e3r/Ly8v/5GRkf//////////////////////////////////////////////////////6NzO/6toHf+oXwb/p18H/6pfBv+oXwn/qGAJ/6hgCf+oYAv/e0UL/5VUDP+lXAj/zaqC//////////////////////+7u7r/jY2N//////////////////////+/v7//gYGB//////+enp7/Ozs7/3h4eP/BwcH//////8jIyP9QUFD/19fW///////m5ub/sLCw/0BAP/+CgYH/urq6//Tz8/9UVFP/SUhI/6qqqv/V1dX/2dnZ/3t6ev/v7+///////6+urv/f39//+vr6/4GBgf+ioqL///////////////////////////////////////////////////////r49f+3hU3/plwH/6ZfCf+lXgr/p14K/6heCf+pXwj/q2EH/3lDCf+OUQv/pV0G/8+uh///////////////////////uLi4/46Ojv//////////////////////wcHB/4GAgP//////8PDw/5iYmP+kpKT/8vLy///////+/v7/7+7u//7+/v/8/Pz/f35+/0lJSf8wMDD/k5OT//39/f//////3d3d/7i4uP/x8fH////////////39/f//v7+///////5+fn//v7+///////8/Pz/+/v7////////////////////////////////////////////////////////////xa2R/5pZC/+sYAf/qmAH/6lfB/+nXwj/p18I/6thB/91Qgr/iE4K/6deBf/StJD//////////////////////7a2tv+Ojo7//////////////////////8PDw/9/f3///////////////////////////////////////////////////////+vr6//w8PD/n56e/6Kiof///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////9LPzf9ZOhz/l1UL/6pfCv+pXwj/pl8I/6dfCP+sYAf/c0EK/4BIC/+rXgf/07aV//////////////////////+1tbX/j4+P///////////////////////Jycn/e3t7///////8/Pz/+vr6//j4+P/19PT/8vLy//Hx8f/w8PD/8PDw//Ly8v///////////8nJyP+IiIj//////////////////////////////////////////////////////////////////////////////////////////////////////////////////v7+//bz8P/////////////////19fX/SUhK/zgeBv+VVg3/qWAI/6RfCf+mXgr/qWAK/3RBC/91Qgz/ql4I/9S4l///////////////////////t7e3/4uLi//v7u7/1NTU/7i4uP+enp3/b29v/zU1Nf9mZmb/XFxc/1hYWP9VVVT/UE9P/0xMS/9KSUn/SEhI/0ZGRv93d3f/9/f3///////h4eH/gYGB//v7+//////////////////////////////////////////////////////////////////////////////////////////////////////////////////VxbP/4tXG/////////////////46Ojv8DAQH/PCEK/5RUD/+rYQj/ql8H/6tgCP93Qwr/aTsM/6heCf/Vupv////////////w8PD/wMDA/2trav81NDT/U1NT/1FRUf9cXFz/bm1t/2dmZv9FRUX/np6e/6Wlpf+urq3/uLi3/7+/v//Dw8P/xMPD/8PDw//CwsL/2dnZ////////////8PDv/4ODg//19fX/////////////////////////////////////////////////////////////////////////////////////////////////////////////////6d3P/7CASP/j1ML////////////Pz8//FhYW/wIAAf81HAf/fEYO/5VWD/+mXwr/fEUJ/1szCv+nXwr/172e////////////nJyc/2dnZ/9eXV3/bm5u/9vb2//v7+//+vr6///////U1NT/d3d3//////////////////////////////////////////////////////////////////b29v+KiYn/8PDw//////////////////////////////////////////////////////////////////////////////////////////////////////////////////z7+v+8j1r/qW0p/9rItP//////9/j4/0tLS/8AAAD/AgAB/xAHA/8oFQf/iE0M/4NJCv9OKwn/pV4L/9nAo////////v7+/+/v7//+/v7/tra1/5SUk///////////////////////1NTU/3Jycv/8/Pz////////////////////////////////////////////////////////////6+vr/lJSU/+/v7///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////2sau/6NeDf+oZxz/y66M//v28P+TlJb/AQAC/wIAAf8AAAL/BAEE/3hDC/+KTQn/QSQJ/6FcC//bwqX//////////////////////7Ozs/+Tk5P//////////////////////9XU1P9vb2//+/v7////////////////////////////////////////////////////////////+vr6/5eXlv/v7+////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////Tv6P+zeTX/plwG/6JeDv+1hk3/s5yC/yQZEv8JAwH/DwYD/xoLBf9yPwn/kFEK/zYdCf+aWAz/3cOm//////////////////////+ysrL/lJSU///////////////////////X1tb/a2tr//n5+f////////////////////////////////////////////////////////////r6+v+bm5v/8fHx////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////yaeA/6NcCf+mXgv/pl0H/6VfDv+MURD/ekUL/39IDv9jOQ//ajwJ/5VUCv8tGAj/j1EM/97Ep///////////////////////srKy/5WVlf//////////////////////3Nvb/2xsbP/4+Pj////////////////////////////////////////////////////////////4+Pj/o6Oj//b29v///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////+jbzP+taBn/qF4H/6peCP+oXgf/qmAI/6thCf+tYQr/eEQJ/2A1Cf+ZVwn/KRUG/3xHDP/dxKj//////////////////////7Gxsf+Wlpb//////////////////////+Dg4P9tbW3/9vb2////////////////////////////////////////////////////////////+Pj4/9XV1P/+/v3////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////7+ff/vItS/6hcBP+oXwj/qF8J/6hfCf+oXwn/qmAJ/3hECf9ULgj/m1gK/yYUBf9nOwz/3MSn//////////////////////+wsLD/l5eX///////////////////////j4+P/aGho//Pz8////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////9e+ov+oXwv/qF4J/6hfCf+oXwn/qF8J/6pgCf97Rgr/RycJ/55aC/8pFwX/Ty0J/9rCpf//////////////////////rq6u/5iYmP//////////////////////5eXl/2VlZf/x8fH////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////y6+P/r3Qw/6hdB/+oXwn/qF8J/6hfCf+pYAj/f0cK/zogCP+cWQv/NRwF/zYeCP/TvaL//////////////////////62trf+ampr//////////////////////+np6f9nZmb/7+/v/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////v///8aheP+kXAf/p18J/6hfCf+oXwn/qWAI/4RKC/8wGgj/mlgL/0QlB/8gEQf/yLSf//////////////////////+rq6v/m5ub///////////////////////r6+v/aWlp/+7u7v/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////l1cP/qWYY/6heCP+oXwj/qF8J/6lgCf+JTQv/KBUH/5NTCv9OKwn/DwcE/7mpnP//////////////////////qKio/56dnf//////////////////////7e3t/2lpaf/t7e3/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////+vf0/7uHS/+mXAX/qF8I/6hfCf+pYAn/jlEK/yERBf+ITAv/WDEJ/wYBAP+km5X//////////////////////6ampv+enp7//////////////////////+/v7/9nZ2f/6enp///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////Uupz/pl4L/6deCf+oXwn/qWAJ/5RUCf8dDwb/dkMK/3RGFf8FAgL/kY+O//////////////////////+mpqX/oKCg///////////////////////w8PD/ZmZm/+bm5v//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////8enf/65xLP+mXQj/qWAH/6hfCf+YVwr/HhAH/2E1B/+cazP/GBYU/4SEhP//////////////////////paWl/6Ghof//////////////////////8/Pz/2lpaP/j4+P///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////7+/v/CnXP/p10E/6pgBv+qYAf/nVoK/yQUBv9HJgT/s39E/0E/Pf94eHj//////////////////////6Wlpf+hoaH///////////////////////b29v9ra2v/4ODg////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////49LA/6lkFP+lXgn/qV8I/6BcCf8tGQb/MBkD/7J8Pv96dXH/c3N0//////////////////////+kpKT/o6Oj///////////////////////39/f/a2pq/93d3f////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////n28/+2hEn/pVwG/6hgB/+nYQz/TzQY/xsNBP+haiz/saie/3p6ev//////////////////////pKSk/6Ojo///////////////////////+Pj4/2lpaf/a2tr/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////07ma/6dfCv+mXwn/qmIM/4tvTf8XERD/iFYe/9bIuf+VlJX//Pz8/////////////////6SkpP+jo6P///////////////////////r6+v9tbW3/19fX//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////Do3/+vcir/p10H/6deBv+3l3L/NjQ1/2k+Ef/iz7r/wMDB//j4+P////////////////+jo6P/o6Oi///////////////////////7+/v/cXFx/9TU1P/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////+/v7/x59x/6ZdBv+mXQT/xp9x/3V1dv9KKAf/2sGl//P09f/8/Pz/////////////////oqKi/6Kiov///////////////////////f39/3Jycv/Pz8///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////+TUwv+lZRj/plwC/8GRWf+5uLj/OCMQ/8aphv///////////////////////////6Kiov+ioqL///////////////////////7+/v90c3P/ysrK///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////6+PX/uYhO/6ZaAf+4gD//5+Th/05COP+pimn///////////////////////////+hoaH/oqKi////////////////////////////eXl5/8jIyP///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////9a9oP+lXQr/sHEp//Tt5f+HgoD/imxN//78+f//////////////////////oaGh/6Kiof///////////////////////////3x8e//Hx8f////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////z6+P/snUu/6llFv/s39D/yMjI/3NbRv/28ez//////////////////////6Ojo/+hoKD///////////////////////////99fHz/xcXF/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////8ijeP+lXQr/4Mmu//P19v98bGD/5NzV//////////////////////+ko6P/oKCg////////////////////////////fX19/8HBwf/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////o2sn/qGYX/86uiv//////pJ2X/83Eu///////////////////////o6Oj/56env///////////////////////////39/fv+7u7v/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////+/r4/7qKUf+9kmH//////9bS0P++ta///////////////////////6SkpP+ampr///////////////////////////+Dg4L/uLi4///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////awqf/s39C//j07//19fX/xcC9//39/f////////////////+lpaX/lpaW////////////////////////////ioqK/7a2tf//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////9O/n/7SGUP/s4NL//////+Lg3v/5+Pj/////////////////p6em/5SUlP///////////////////////////42Njf+zs7P////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////Nrov/28at///////7+/v//f39/////////////////6ysrP+TkpL///////////////////////////+Pj4//r6+v////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////69/R/82zlf////////////////////////////////+vr6//kJCQ////////////////////////////j4+P/6urq/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////z7+f/SvaX/+PTw////////////////////////////sbGx/42Njf///////////////////////////5GRkf+np6f/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////5tzS/+zl3////////////////////////////7Ozs/+Mi4v///////////////////////////+VlZT/paWl//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////j29f/o493///////////////////////////+0tLT/hYSE////////////////////////////mZmZ/6Wlpf//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////8vDv//z8/P//////////////////////ubm5/39/f////////////////////////////5ycnP+jo6P///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////39/f/+/v3//////////////////////8HBwf96enr///////////////////////////+rq6r/vb29///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////Gxsb/dHR0//7+/v//////////////////////6urp//b29v//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////zMzM/3Jycv/9/f3//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////9HR0f9qamr/+/v7///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////X19f/dHR0//v7+///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////6Ojo/8TExP//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA='