#include 'fileio.ch'
#include 'common.ch'
#include 'hbclass.ch'

function error4()

	local a 	:= version()
	local cHtml := ''
	local u
	

		BLOCKS TO cHtml PARAMS a
			La Maria 
			se marcho de viaje
			
			a ->  {{ a 	}} 
			
			Ultima Linea

		ENDTEXT 
		
//a+1	

		BLOCKS TO cHtml PARAMS a
			Una linea
			Dos linees
			Tres linees
			
			Test a->  {{ a }} 	
			Test abc->  {{ a }} 	//	change a for abc 
			
			Antepenultima Linea
			Penultima Linea
			Ultima Linea

		ENDTEXT 		
		
	 ? cHtml
	
	? 'Fin a las ' , time()
	
//	Error tests...	
? a()
//u := date(   
//u := xxxx()				//	No pillo linea, si error
//u := substr( a )
//? 5/0
//use tttt
//a+


	
retu nil
	
function a()
retu b()

function b()

retu c()

function c()

	local a := 5
	local b := .t.
	local c := a + b
	

	//a+5
	
retu .t.