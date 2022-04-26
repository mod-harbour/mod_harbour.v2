function OpenData()
	
	local cPath := hb_GetEnv( 'PRGPATH' )
	
	if !file( cPath + '/order.dbf' ) 
	
		DbCreate( cPath + '/order.dbf',;		
				{ 	{'DATE', 'D', 8, 0 },;
					{ 'TIME', 'C', 8, 0},;
					{ 'USER', 'C', 10, 0},;
					{ 'IP', 'C', 18, 0},;
					{ 'CAR', 'C', 10, 0 },;
					{ 'Qty', 'N', 8, 0 };
				})																				
	endif 
	
	SET DATE TO ITALIAN
	
	USE ( cPath + '/order' ) SHARED NEW 	

retu Alias()

//	--------------------------------------------------------	//

function MyNav( cName, aItems ) 

	local cHtml 	:= ''
	local cUrl 	:= mh_GetUri()	
	
	BLOCKS TO cHtml PARAMS cName 
	
		<nav class="navbar navbar-dark bg-dark">
		  <a class="navbar-brand" href="#">{{ cName }}</a>
		  
		  <div class="dropdown ">
			<button class="btn btn btn-outline-warning dropdown-toggle" type="button" data-toggle="dropdown">
				Options
			</button>
			
			<ul class="dropdown-menu pl-2">
			
	ENDTEXT 
	
	for n := 1 to len( aItems )
	
		cHtml += '<li class="p-2"><a href="' + cUrl + aItems[n][2] + '">' + aItems[n][1] + '</a></li>'
		
	next 
			  
	BLOCKS TO cHtml PARAMS cName 	
	
			</ul>			
		  </div>		  
		</nav>			
	ENDTEXT 	


retu cHtml 