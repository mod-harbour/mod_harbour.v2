//----------------------------------------------------------------//

function Main()
   
	local hCookies 	:= GetCookies()
	local hKey 		:= nil 
	
	?? 'GetCookies()'
	
	for each hKey in hCookies
	
		? hKey:__ENUMKEY(), "=>", hKey:__ENUMVALUE()
	
	next 
	
	? '<hr>'
	
	? 'GetCookies( "MYCookiENamE" )', GetCookies( "MYCookiENamE" )
	
return nil

//----------------------------------------------------------------//
