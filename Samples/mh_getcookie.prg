//----------------------------------------------------------------//

function Main()
   
	local hCookies 	:= MH_GetCookies()
	local hKey 		:= nil 
	
	?? 'GetCookies()'
	
	for each hKey in hCookies
	
		? hKey:__ENUMKEY(), "=>", hKey:__ENUMVALUE()
	
	next 
	
	? '<hr>'
	
	? 'MH_GetCookies( "MYCookiENamE" )', MH_GetCookies( "MYCookiENamE" )
	
return nil

//----------------------------------------------------------------//
