function main()

	? 'hb_GetEnv( "PRGPATH" )', ' => ', hb_GetEnv( "PRGPATH" )
	? 'ap_GetEnv( "SCRIPT_FILENAME" )', ' => ', ap_GetEnv( "SCRIPT_FILENAME" )
	? 'hb_FNameDir( AP_GetEnv( "SCRIPT_FILENAME" ) )', ' => ', hb_FNameDir( AP_GetEnv( "SCRIPT_FILENAME" ) )
	? 'ap_Filename()', ' => ', ap_FileName()
	? 'mh_GetUri()', ' => ', mh_GetUri()			
	? 'mh_PathUrl()', ' => ', mh_PathUrl()			
	? 'mh_PathBase()', ' => ', mh_PathBase()	
	
	? 'mh_ModBuildDate()', ' => ', mh_ModBuildDate()			
	? 'mh_ModName()', ' => ', mh_ModName()			
	? 'mh_ModVersion()', ' => ', mh_ModVersion()			
	
retu nil 	