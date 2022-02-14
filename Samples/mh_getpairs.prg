function Main()

	local cUrl := ap_getenv( 'SCRIPT_NAME' ) + '?one=first&two=second&three=third'

	? 'AP_Args()', ap_Args()
	? 'AP_GetPairs()', mh_ValToChar( AP_GetPairs() )
   
	? 'Test =>' , '<a href="' + cUrl + '" >' + cUrl + '</a>'

retu nil
