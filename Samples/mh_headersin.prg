function main()
	
	local hHeaders 	:= AP_HeadersIn()
	local hKey 		:= nil 
	
	for each hKey in hHeaders
	
		? hKey:__ENUMKEY(), "=>", hKey:__ENUMVALUE()
	
	next 
   
retu nil
