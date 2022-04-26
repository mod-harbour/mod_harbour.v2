//	Autentication ----------

	if ! mh_SessionActive()
	
		mh_Redirect( mh_GetUri() + 'login.prg')
		
		retu nil	
		
	endif 
	
	mh_SessionInit()			
//	------------------------