/*
** persistence.prg -- persistence module
** (c) DHF, 2020-2021
** MIT license
*/

// ----------------------------------------------------------------//

FUNCTION MH_HashGet( cKey, xDefault )

   LOCAL xRet

   hb_default( @xDefault, NIL )
   while !hb_mutexLock( mh_Mutex() )
   enddo
   xRet := hb_HGetDef( mh_Hash(), cKey, xDefault )
   hb_mutexUnlock( mh_Mutex() )

RETURN xRet

// ----------------------------------------------------------------//

FUNCTION MH_HashSet( cKey, xValue )

   while !hb_mutexLock( mh_Mutex() )
   enddo
   hb_HSet( mh_Hash(), cKey, xValue )
   hb_mutexUnlock( mh_Mutex() )

RETURN

// ----------------------------------------------------------------//