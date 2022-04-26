function main()

	local cHtml := ''
	local cUrl 		:= mh_GetUri()
	
	//	Autentication ----------
		
		{% mh_LoadFile( 'autentication.prg' ) %}

	
	BLOCKS TO cHtml PARAMS cUrl 
	
		{{ mh_View( 'header.prg', 'Main Screen' ) }}
		
		<a href="{{ cUrl + 'entry.prg' }}" ><button>Order</button></a> 
		<a href="{{ cUrl + 'list.prg' }}" ><button>List</button></a> 	
		<a href="{{ cUrl + 'exit.prg' }}" ><button>Exit</button></a>	 			
	
	ENDTEXT 
	

	?? cHtml

retu nil 