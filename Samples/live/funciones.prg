function main()

	local hParam := ap_PostPairs()
	
	AP_SetContentType( "application/json" )
	
	do case
		case hParam[ 'action' ] == 'test1' ; MyTest1( hParam )
		case hParam[ 'action' ] == 'test2' ; MyTest2( hParam )
		otherwise			
	
			?? hb_jsonEncode( { 'error' => 'Accion no permitida' } )
	endcase
	
retu nil 

function MyTest1( hParam )
	
	?? hb_jsonEncode( hParam )
	
retu nil 

function MyTest2( hParam )	
	
	?? hb_jsonEncode( hParam )
	
retu nil 
