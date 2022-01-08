/*
**  mh_persistent.prg -- Apache harbour module V2
**  MH_HASH Persistense test sample - 
** (c) DHF, 2020-2021
*/

FUNCTION test()

   IF mh_HashGet( 'var' ) != NIL
      mh_HashSet( 'var', mh_HashGet( 'var' ) + 1 )
   ELSE
      mh_HashSet( 'var', 1 )
   ENDIF

   ? "MH_HASH['var'] value: ", mh_HashGet( 'var' ) 

RETURN NIL
