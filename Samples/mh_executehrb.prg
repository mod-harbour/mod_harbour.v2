function main()

	local cFile := hb_GetEnv( 'PRGPATH' ) + '/' + 'module_a.hrb'

	? mh_ExecuteHrb( hb_memoread( cFile ) )
	
retu nil 