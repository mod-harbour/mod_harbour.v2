function main()

	local hData := {=>}


	hData[ 'string'  ] := 'Hello world'
	hData[ 'numeric' ] := 1234
	hData[ 'date'    ] := date()
	hData[ 'logic'   ] := .T.						
	hData[ 'array'   ] := { 'Rambo', 1234, date()}
	hData[ 'class'   ] := ErrorNew()
	hData[ 'dummy_h' ] := {=>}
	hData[ 'dummy_a' ] := {}
	
		?? '<b>Test Logs</b><hr>'
		

	//	Output console DbWin32
	
		?? 'Check DBwin32<hr>'		
		
		_d( 'Test Debug for Windows...' )
		_d( 1234 )
		_d( date() )
		_d( .T. )
		_d( hData )		
		
		_d( '===== Multiple Vars =========' )	
		_d( 'Hello var', 1234, date(), { 'var1' => 123 }, {}, NIL )
		_d( '=============================' )


		
	//	Output to logfile
	
		?? 'Check log file', MH_Log_File(), '<hr>'	
		
		_l()												//	Delete log file
		_l( '*** LOG ***' )
		_l( hData )		
		
		MH_Log_File( hb_getenv( 'PRGPATH') + '/trace/log2.txt' )	//	Declare new log file	
		
		?? 'Check new log file', MH_Log_File(), '<hr>'	
		
		_l( 'New log...')
		_l( time() )
	
	
	//	Output Web screen
	
		?? '<b>Web Screen</b><hr>'		
		
		_w( 'Test Debug for Windows...' )
		_w( 1234 )
		_w( date() )
		_w( .T. )
		_w( hData )		
		
		_w( '===== Multiple Vars =========' )	
		_w( 'Hello var', 1234, date(), { 'var1' => 123 }, {}, NIL )
		_w( '=============================' )	
	
	
	
	
	
retu nil
