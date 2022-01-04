function main()

	MH_ErrorBlock( {|oError| MyError( oError ) } )
	
	? a + 5
	
retu nil 

function MyError( oError )

	? 'Description:'//, oError:description 
	
retu nil 