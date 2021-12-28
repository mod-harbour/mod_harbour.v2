/*
** persistence.prg -- persistence module
** (c) DHF, 2020-2021
** MIT license
*/

// ----------------------------------------------------------------//

FUNCTION HW_HashGet( cKey, xDefault )

   LOCAL xRet

   hb_default( @xDefault, NIL )
   hb_mutexLock( HW_Mutex() )
   xRet := hb_HGetDef( HW_Hash(), cKey, xDefault )
   hb_mutexUnlock( HW_Mutex() )

RETURN xRet

// ----------------------------------------------------------------//

FUNCTION HW_HashSet( cKey, xValue )

   hb_mutexLock( HW_Mutex() )
   hb_HSet( HW_Hash(), cKey, xValue )
   hb_mutexUnlock( HW_Mutex() )

RETURN

// ----------------------------------------------------------------//