/*
** persistence.prg -- persistence module
** (c) DHF, 2020-2021
** MIT license
*/

/*	
	You can delimit the scope of the variables, defining their namespace.

	For example, if 2 applications are installed on the same server.
	Each application may have its namespace
	
	By default the values are saved in the same space	
*/

// ----------------------------------------------------------------//

FUNCTION MH_HashGet( cKey, xDefault, cNameSpace )

   LOCAL xRet, hPersistent 

   hb_default( @xDefault, NIL )
   hb_default( @cNameSpace, 'public' )
   
   while !hb_mutexLock( mh_Mutex() )
   enddo
   
   hPersistent := mh_Hash()
   
   HB_HCaseMatch( hPersistent, .f. )
   
    if !HB_HHasKey( hPersistent, cNameSpace )
		xRet := xDefault 
	else	      
		xRet := hb_HGetDef( hPersistent[ cNameSpace ], cKey, xDefault )
	endif 
	
   hb_mutexUnlock( mh_Mutex() )

RETURN xRet

// ----------------------------------------------------------------//

FUNCTION MH_HashSet( cKey, xValue, cNameSpace )

	local hPersistent 

   hb_default( @cNameSpace, 'public' )   

   while !hb_mutexLock( mh_Mutex() )
   enddo
   
   hPersistent := mh_Hash()

   HB_HCaseMatch( hPersistent, .f. )
   
   if !HB_HHasKey( hPersistent, cNameSpace )		
		hPersistent[ cNameSpace ] := {=>} 
   endif 
  
   hPersistent[ cNameSpace ][ cKey ] := xValue 
  
   hb_mutexUnlock( mh_Mutex() )

RETURN

// ----------------------------------------------------------------//