/* Only for develop	*/

function _d( ... )

	local aParams 	:= hb_AParams()
	local n 		:= Len( aParams )
	local i 
   
	for i = 1 TO n
		WAPI_OutputDebugString( ValToChar( aParams[i] ) + chr(10) + chr(13) )
	next	

retu nil 