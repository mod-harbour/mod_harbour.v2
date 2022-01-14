function main()	

	
		? 'Modules loaded =>', AP_GetEnv( 'MH_INITPROCESS' )	
		
	
		? 'Execute Today() from module_a.hrb =>' , Today()		
		
	
		? 'Execute NextWeek() from module_b.hrb =>' , NextWeek()			
	
	
		? 'Execute Msg() from msg.prg'	

			Msg( 'Test de module' )
	
	
		? 'Execute COMMAND from cmd.ch'	 
		
			TITLE 'Hello prepro'
			LIST  'First'
			LIST  'Second'
			LIST  'Third'

retu nil 