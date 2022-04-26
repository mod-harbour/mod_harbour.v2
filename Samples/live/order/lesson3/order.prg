function main()

	local hParam 
	local cHtml := ''
	local cUrl 		:= mh_GetUri()
	
	//	Autentication ----------
		
		{% mh_LoadFile( 'autentication.prg' ) %}
	
	
	//	Recover parameters 
	
		hParam := ap_PostPairs()
		cUser	:= mh_Session( 'user' )
	
	//	Open Database			
	
		cAlias := OpenData()

		if empty( cAlias )
			? 'Error Opendata'
			retu 
		endif 
	
	//	Save data 
	
		if ( cAlias)->( DbAppend()) 
		
			(cAlias)->date   	:= date()
			(cAlias)->time   	:= time()
			(cAlias)->user   	:= cUser 
			(cAlias)->ip   	:= ap_GetEnv( 'REMOTE_ADDR' )
			(cAlias)->car   	:= hParam[ 'cars' ]
			(cAlias)->qty   	:= Val( hParam[ 'qty' ] )

			(cAlias)->( DbCommit() )
			(cAlias)->( DbUnlock() )		
		
		endif			
	
	//	Show message
	
		BLOCKS TO cHtml 

			{{ mh_View( 'header.view' ) }}			

			<body>
			
		ENDTEXT
			
		cHtml += MyNav( 'Order Updated!', {	;					
							{ 'Entry', 'entry.prg' },;
							{ 'Menu', 'menu.prg' },;
							{ 'List', 'list.prg' },;
							{ 'Exit', 'exit.prg'};
						}) 				
		
				
		BLOCKS TO cHtml 
		
			<b>Resumen Transaction</b>
			<hr>		
		
			<table class="table table-sm table-bordered " >
			<thead class="thead-dark">		
			
				<tr>
					<th>User</th>
					<th>Date</th>
					<th>Time</th>
					<th>IP</th>
					<th>Car</th>
					<th>Qty</th>					
				</tr>	
			</thead>
				
		
		ENDTEXT 
		
			cHtml += '<tr>'
			cHtml += '<td>' + cUser + '</td>'
			cHtml += '<td>' + Dtoc( (cAlias)->date ) + '</td>'
			cHtml += '<td>' + (cAlias)->time + '</td>'
			cHtml += '<td>' + (cAlias)->ip + '</td>'
			cHtml += '<td>' + (cAlias)->car + '</td>'
			cHtml += '<td>' + Str((cAlias)->qty ) + '</td>'
			cHtml += '</tr>'
			
		BLOCKS TO cHtml 
		
			</table>		

			</body>
			</html>				
		
		ENDTEXT 			
	
	//	Generate output	
	
		?? cHtml

retu nil 

{% mh_LoadFile( 'public.prg' ) %}