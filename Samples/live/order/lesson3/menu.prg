function main()

	local cHtml 	:= ''
	
	
	//	Autentication --------------------
	
		{% mh_LoadFile( 'autentication.prg')  %}

	
	BLOCKS TO cHtml 
	
		{{ mh_View( 'header.view' ) }}	
		
		<body>
		
	ENDTEXT 	
	
	cHtml += MyNav( 'Menu', {;
						{ 'Create Order', 'entry.prg' },;
						{ 'List', 'list.prg' },;
						{ 'Exit', 'exit.prg'};
					}) 		

	BLOCKS TO cHtml 
			</body>
		</html>		
	ENDTEXT 
	

	?? cHtml

retu nil 

//	--------------------------------------------------------	//

{% mh_LoadFile( 'public.prg' ) %}