function main()

	local cHtml := ''
	local cUrl 		:= mh_GetUri()
	
	//	Autentication ----------
	
		if ! mh_SessionActive()
		
			mh_Redirect( cUrl + 'login.prg')
			
			retu nil	
			
		endif 
		
		mh_SessionInit()			
	//	------------------------	

	//	Open dbf 
	
		cAlias := OpenData()

		if empty( cAlias )
			? 'Error Opendata'
			retu 
		endif 	
		
		nCount := (cAlias)->( RecCount() )				
	
	//	Show data 

	
	BLOCKS TO cHtml PARAMS cUrl 
	
		<head>
			<title>App Order</title>
			<meta name="viewport" content="width=device-width, initial-scale=1.0">		
		</head>	
	
		<h3>List</h3>
		<hr>

		<b>Total Orders:</b> {{ str( nCount ) }} 
		<hr>
		
		<table border="1">
			<tr>
				<th>User</th>
				<th>Date</th>
				<th>Time</th>
				<th>IP</th>
				<th>Car</th>
				<th>Qty</th>					
			</tr>						
	ENDTEXT 
	
		(cAlias)->( DbGotop() )
	
		while (cAlias)->( !Eof() )
		
			cHtml += '<tr>'
			cHtml += '<td>' + (cAlias)->user + '</td>'
			cHtml += '<td>' + Dtoc( (cAlias)->date ) + '</td>'
			cHtml += '<td>' + (cAlias)->time + '</td>'
			cHtml += '<td>' + (cAlias)->ip + '</td>'
			cHtml += '<td>' + (cAlias)->car + '</td>'
			cHtml += '<td>' + str( (cAlias)->qty ) + '</td>'
			cHtml += '</tr>'											
		
			(cAlias)->( DbSkip() )
		end 
		
	BLOCKS TO cHtml PARAMS cUrl 	
		
		</table>	

		<br> 		
		
		<a href="{{ cUrl + 'menu.prg' }}" ><button>Menu</button></a>
		<a href="{{ cUrl + 'exit.prg' }}" ><button>Exit</button></a>		

	ENDTEXT 
	
	
	?? cHtml


retu nil 

{% mh_LoadFile( 'public.prg' ) %}
