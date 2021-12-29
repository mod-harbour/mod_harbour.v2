function Main()

	local aH := {=>}	
	
	aH[ 'time' ] 	= time()
	aH[ 'date' ] 	= date()
	aH[ 'age'  ] 	= 123
	aH[ 'married' ] = .T.
	
	AP_SetContentType( "application/json" )
	
	?? hb_jsonEncode( aH )	

return nil
