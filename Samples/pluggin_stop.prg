//	{% MH_LoadHrb( 'module_a.hrb' ) %}

/*
	El objetivo de este test es:
		- Carga module_a.hrb, el cual lleva la funcion Today()
		- Espera 10 seg. 
		- Mientras, ejecutamos pluggin.hrb, el cual carga tambien module_a, ejecuta y muere
		- Pasados los 10 seg. se intenta ejecutar la funcion Today() 
			y podemos comprobar si se ha descargado previamente por otro programa			
*/

function main()


	hb_idleSleep( 10 )
	
	? 'Today: ' + Today()
	
retu nil	


