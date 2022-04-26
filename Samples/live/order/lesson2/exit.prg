function main()

	local cUrl 		:= mh_GetUri()

	//	Autentication ----------
		
		{% mh_LoadFile( 'autentication.prg' ) %}

		mh_SessionEnd()
		
		mh_Redirect( cUrl + 'index.html')


retu nil 