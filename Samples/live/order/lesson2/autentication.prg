//	Autentication ----------

	if ! mh_SessionActive()
	
		mh_Redirect( cUrl + 'login.prg')
		
		retu nil	
		
	endif 
	
	mh_SessionInit()			
//	------------------------	