function main()

	local hParam := ap_PostPairs()
	local cUrl 		:= mh_GetUri()
		
	//	Recover data
	
	
	//	Check data 
	
	if !empty( hParam[ 'user' ] ) .and. hParam[ 'psw' ] == '1234' 
	
		mh_SessionInit()
		
		mh_Session( 'user', lower( hParam[ 'user' ] ) )			
		
		cUrl += 'menu.prg'
	
	else 
	
		cUrl += 'login.prg'
	
	endif 
	
	mh_Redirect( cUrl )
	

retu nil 