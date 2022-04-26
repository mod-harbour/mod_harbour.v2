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
	
	USE ( cPath + '/order' ) SHARED NEW 	

retu Alias()