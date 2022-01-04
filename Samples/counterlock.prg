//	Counter with sleep...

function main()	

	local cDbf 		:= hb_getenv( 'PRGPATH' ) + '/counter.dbf'
	local cAlias 
	
	use (cDbf) shared new 	
	
	cAlias := alias()		
	
	LOCATE FOR (cAlias)->id = 'order'
	
	if (cAlias)->( Found() )
		
		(cAlias)->( Rlock() )
		
	endif		
	
	hb_idleSleep( 5 )	//	wait 
	
	(cAlias)->( DbCloseArea() )	
	
	? 'Counter unlock!'
	
retu nil 
