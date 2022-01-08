//	{% MH_LoadHrb( 'module_a.hrb' ) %}
//	{% MH_LoadHrb( 'module_b.hrb' ) %}

function main()

	//	From module_a
		? 'Version Plug: ', PlugVersion()
		? 'Today: ', Today()
		
	//	From module_b
		? 'NextWeek: ' , DToC( NextWeek() )

	
retu nil	


