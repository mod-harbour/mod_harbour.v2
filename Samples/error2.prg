function main()

	MH_ErrorBlock( {|hError| MyError( hError ) } )
	
	? a + 5
	
retu nil 

function MyError( hError )

	? hError
	
retu nil 