function main()

	local hParam 
	local cHtml := ''
	local cUrl 		:= mh_GetUri()
	
	//	Autentication ----------
	
		if ! mh_SessionActive()
		
			mh_Redirect( cUrl + 'login.prg')
			
			retu nil	
			
		endif 
		
		mh_SessionInit()			
	//	------------------------	
	
	
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
		
			<head>
				<title>App Order</title>
				<meta name="viewport" content="width=device-width, initial-scale=1.0">		
			</head>		
		
			<h3>Order</h3>
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
		
			cHtml += '<tr>'
			cHtml += '<td>' + cUser + '</td>'
			cHtml += '<td>' + Dtoc( (cAlias)->date ) + '</td>'
			cHtml += '<td>' + (cAlias)->time + '</td>'
			cHtml += '<td>' + (cAlias)->ip + '</td>'
			cHtml += '<td>' + (cAlias)->car + '</td>'
			cHtml += '<td>' + Str((cAlias)->qty ) + '</td>'
			cHtml += '</tr>'
			
		BLOCKS TO cHtml PARAMS cUrl
		
			</table>
			
			<br> 
			
			<a href="{{ cUrl + 'entry.prg' }}" ><button>Entry</button></a>
			<a href="{{ cUrl + 'menu.prg' }}" ><button>Menu</button></a>
			<a href="{{ cUrl + 'exit.prg' }}" ><button>Exit</button></a>
			
		
		ENDTEXT 		
		
		
		
	
	
	//	Close All 
	
	
	//	Generate output	
	
		?? cHtml

retu nil 

{% mh_LoadFile( 'public.prg' ) %}


