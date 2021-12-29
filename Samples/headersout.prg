function Main()

	local hHeaders, hKey

	AP_HeadersOutSet( "one", "first" )
   
	SetCookie( "two", "second" )

	hHeaders := AP_HeadersOut()
   
	for each hKey in hHeaders
	
		? hKey:__ENUMKEY(), "=>", hKey:__ENUMVALUE()
	
	next    

return nil
