function Main()

	??  '<h2>Test Sessions. Recover values...</h2><hr>'

	? 	'<h3>'
	?  	'<li>Init Session => mh_SessionInit() </li>'
	
		mh_SessionInit()
	
	?	'<li>Recover values from session'		
	?	"=> mh_Session( 'dni' )"
	?	"=> mh_Session( 'time' )"
	?	"=> mh_Session( 'today' ) <-- this var doesn't exist"
	? 	'</li>'

	? 	'Var. DNI: '	, mh_Session( 'dni' )				
	? 	'Var. Time: ' 	, mh_Session( 'time' )	
	? 	'Var. Today: ' 	, mh_Session( 'today' ) 		// First time doesn't exist	
	? 	'</li>'
	
	?	"<li>Now, we'll update 'time' and will create 'today'"		
	?	"=> mh_Session( 'time', time() )"
	?	"=> mh_Session( 'today', date() )"
	? 	'</li>'

		mh_Session( 'time', time() )	//	Update 'time'
		mh_Session( 'today', date() )	//	New var 'today' 

		
	? "<hr><h4>That's all. Now you can refresh page and you will be new values - <a href='session_read.prg'>Refresh session_read.prg</a>"				
	? "Or you can go to another page and you can see how delete Session - <a href='session_end.prg'>session_end.prg</a></h4><hr>"				
		
		
		
retu nil 