function main()

	?? '<h3>Modules</h3><hr>'		
	
	? 'V2 will load modules =>', AP_GetEnv( 'MH_INITPROCESS' )
	
	//	Execute func Today() from module_a
	
	? 'Today() from module_a.hrb' , Today()		

retu nil 