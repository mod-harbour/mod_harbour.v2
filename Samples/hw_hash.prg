/*
**  hw_hash.prg -- Apache harbour module V2
**  HW_HASH Persistense test sample - 
** (c) DHF, 2020-2021
*/

FUNCTION test()

   IF HW_HashGet( 'var' ) != NIL
      HW_HashSet( 'var', HW_HashGet( 'var' ) + 1 )
   ELSE
      HW_HashSet( 'var', 1 )
   ENDIF

   ? "HW_HASH['var'] value: ", HW_HashGet( 'var' ) 

RETURN NIL
