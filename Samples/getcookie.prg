//----------------------------------------------------------------//

function Main()
   
	local hCookies 	:= GetCookies()
	local hKey 		:= nil 
	
	for each hKey in hCookies
	
		? hKey:__ENUMKEY(), "=>", hKey:__ENUMVALUE()
	
	next 
	
return nil

//----------------------------------------------------------------//
