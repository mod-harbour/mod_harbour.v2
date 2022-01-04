function main()

	MH_ErrorBlock( {|oError| MyError( oError ) } )
	
	? a + 5
	
retu nil 

function MyError( oError )

	? oError		
	
retu nil 