function Main()

	??  '<h2>Test Sessions. Destroy sessions</h2><hr>'

	? 	'<h3>'
	?  	'<li>We can verify if exist exist => mh_SessionActive() </li>'

		if  ! mh_SessionActive()
			? "<hr><h4>No session active - <a href='session.prg'>Init session session.prg</a>"
			retu nil
		endif

	?  	'<li>Close Session => mh_SessionEnd() </li>'		
	
		mh_SessionEnd()	
		
	? 	"<hr><h4>That's all. Session was destroyed. Now you can refresh page - <a href='session_end.prg'>Refresh session_end.prg</a>"		

return nil 