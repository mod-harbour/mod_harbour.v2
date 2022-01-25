function Main()

	??  '<h2>Test Sessions. Destroy sessions</h2><hr>'

	? 	'<h3>'
	?  	'<li>We can verify if exist exist => mh_IsSession() </li>'

		if  ! mh_IsSession()
			? "<hr><h4>No session exists - <a href='session.prg'>Init session session.prg</a>"
			retu nil
		endif
		
	?  	'<li>Init Session => mh_InitSession() </li>'
	
		mh_InitSession()

	?  	'<li>Close Session => mh_EndSession() </li>'		
	
		mh_EndSession()	
		
	? 	"<hr><h4>That's all. Session was destroyed. Now you can refresh page - <a href='session_end.prg'>Refresh session_end.prg</a>"		

return nil 