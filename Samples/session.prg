function main()

	local cDni 	:= '39690495X'
	local cTime := time()

	?? '<h2>Test Sessions. Save values...</h2><hr>'
	
	? 	"<h3>"
	?  	"<li>Init Session => mh_SessionInit() </li>"
	
		mh_SessionInit( nil, 5 )		


	?	"<li>Show vars"
	? 	"=> local cDni :=" , cDni
	? 	"=> local cTime :=" , cTime
	? 	"</li>"
	
	
	?	"<li>Save my vars into session"		
	?	"=> mh_Session( 'dni',  cDni )"
	?	"=> mh_Session( 'time', cTime )"
	? 	"</li>"
	
		mh_Session( 'dni',  cDni )
		mh_Session( 'time', cTime )				

	? "<hr><h4>That's all. Now you can go to another page and retrieve this session and its variables stored in it - <a href='session_read.prg'>session_read.prg</a></h4><hr>"				

retu nil 