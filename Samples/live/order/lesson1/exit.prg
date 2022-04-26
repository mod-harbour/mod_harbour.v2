function main()

	local cUrl 		:= mh_GetUri()

	//	Autentication ----------
	
		if ! mh_SessionActive()
		
			mh_Redirect( cUrl + 'login.prg')
			
			retu nil	
			
		endif 
		
		//mh_SessionInit()
		
	//	------------------------	

		mh_SessionEnd()
		
		mh_Redirect( cUrl + 'index.html')


retu nil 