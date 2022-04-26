function main()

	local cHtml := ''
	local cUrl 		:= mh_GetUri()
	
	//	Autentication ----------
		
		{% mh_LoadFile( 'autentication.prg' ) %}

	//	Open dbf 
	
		cAlias := OpenData()

		if empty( cAlias )
			? 'Error Opendata'
			retu 
		endif 	
		
		nCount := (cAlias)->( RecCount() )				
	
	//	Show data 

	

	BLOCKS TO cHtml 
	
		{{ mh_View( 'header.view' ) }}	
		
		<body>
		
	ENDTEXT  	

	cHtml += MyNav( 'List', {	;					
						{ 'Menu', 'menu.prg' },;
						{ 'Exit', 'exit.prg'};
					}) 		
	
	BLOCKS TO cHtml 
	
		<div class="content" style="overflow: auto;">
		<p class="p-2"><b>Total Orders:</b> {{ str( nCount ) }} </p>		
		
		<table class="table table-sm table-striped table-bordered table-hover " >
		<thead class="thead-dark">
			<tr>
				<th>User</th>
				<th>Date</th>
				<th>Time</th>
				<!--<th>IP</th>-->
				<th>Car</th>
				<th>Qty</th>					
			</tr>						
		</thead>
	ENDTEXT 
	
		(cAlias)->( DbGotop() )
	
		while (cAlias)->( !Eof() )
		
			cHtml += '<tr>'
			cHtml += '<td>' + (cAlias)->user + '</td>'
			cHtml += '<td>' + Dtoc( (cAlias)->date ) + '</td>'
			cHtml += '<td>' + (cAlias)->time + '</td>'
			//cHtml += '<td>' + (cAlias)->ip + '</td>'
			cHtml += '<td>' + (cAlias)->car + '</td>'
			cHtml += '<td>' + str( (cAlias)->qty ) + '</td>'
			cHtml += '</tr>'											
		
			(cAlias)->( DbSkip() )
		end 
		
	BLOCKS TO cHtml 
		
		</table>	

		</body>
		</html>		

	ENDTEXT 	
	
	?? cHtml

retu nil 

//	--------------------------------------------------------	//

{% mh_LoadFile( 'public.prg' ) %}
