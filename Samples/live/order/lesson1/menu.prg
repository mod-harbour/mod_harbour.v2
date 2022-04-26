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

	
	BLOCKS TO cHtml PARAMS cUrl 
	
		<head>
			<title>App Order</title>
			<meta name="viewport" content="width=device-width, initial-scale=1.0">		
		</head>	
	
		<h3>Menu</h3>
		<hr>
		
		<a href="{{ cUrl + 'entry.prg' }}" ><button>Order</button></a> 
		<a href="{{ cUrl + 'list.prg' }}" ><button>List</button></a> 	
		<a href="{{ cUrl + 'exit.prg' }}" ><button>Exit</button></a>	 			
	
	ENDTEXT 
	

	?? cHtml

retu nil 