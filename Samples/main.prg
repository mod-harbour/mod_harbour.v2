/*
 The first function we declare will always be executed.
 If we have defined INIT PROC <cName>, it will always be
 executed before the first function declared. We can have
 several INIT PROC, which will be executed sequentially
 LIFO style 
*/

function Mary()

	? "I'm Mary() the first funcion ->", time() + ' ' + dtoc( date() )

retu nil

function OtherFunc()
	
	? "I'm otherfunc()"
	
retu 

INIT PROC Main

	? "I'm Main "
	
retu nil 

INIT PROC Main2
	
	? "I'm Main2 "
	
retu nil 