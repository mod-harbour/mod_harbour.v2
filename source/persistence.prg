/*
** persistence.prg -- persistence module
** (c) DHF, 2020-2021
** MIT license
*/

// ----------------------------------------------------------------//

FUNCTION HW_HashGet( cKey, xDefault )

   LOCAL xRet

   hb_default( @xDefault, NIL )
   while !hb_mutexLock( HW_Mutex() )
   enddo
   xRet := hb_HGetDef( HW_Hash(), cKey, xDefault )
   hb_mutexUnlock( HW_Mutex() )

RETURN xRet

// ----------------------------------------------------------------//

FUNCTION HW_HashSet( cKey, xValue )

   while !hb_mutexLock( HW_Mutex() )
   enddo
   hb_HSet( HW_Hash(), cKey, xValue )
   hb_mutexUnlock( HW_Mutex() )

RETURN

// ----------------------------------------------------------------//