function main()	
	
	? '<li>InitProcess will load modules =>', AP_GetEnv( 'MH_INITPROCESS' )
	
	//	Execute func Today() from module_a
	
	? '<li>Execute Today() from module_a.hrb =>' , Today()		
	
	? '<li>Execute Msg() from msg.prg'
	
	Msg( 'Test de module' )

retu nil 