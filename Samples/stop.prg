function main()

	local n := seconds()	
	
	hb_idleSleep( 20 )	//	wait 10 sec
	
	? seconds() - n, 'sec.'
	
retu nil 
