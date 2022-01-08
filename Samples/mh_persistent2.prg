/*
**  mh_persistent.prg -- Apache harbour module V2
**  MH_HASH Persistense test sample - 
** (c) DHF, 2020-2021
*/

/*	
	You can delimit the scope of the variables, defining their namespace.

	For example, if 2 applications are installed on the same server.
	Each application may have its namespace
	
	By default the values are saved in the same space	
*/	

FUNCTION main()

   IF mh_HashGet( 'var', nil, 'APP_A' ) != NIL
      mh_HashSet( 'var', mh_HashGet( 'var', nil, 'APP_A' ) + 1, 'APP_A' )
   ELSE
      mh_HashSet( 'var', 1, 'APP_A' )
   ENDIF
   
   IF mh_HashGet( 'var', nil, 'APP_B' ) != NIL
      mh_HashSet( 'var', mh_HashGet( 'var', nil, 'APP_B' ) - 1, 'APP_B' )
   ELSE
      mh_HashSet( 'var', 1000, 'APP_B' )
   ENDIF   
   
   ? MH_HASH()
   ? '<hr>'

   ? "APP_A MH_HASH['var'] value: ", mh_HashGet( 'var', nil, 'APP_A' ) 
   ? "APP_B MH_HASH['var'] value: ", mh_HashGet( 'var', nil, 'APP_B' ) 

RETURN NIL
