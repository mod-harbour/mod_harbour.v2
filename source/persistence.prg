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

   LOCAL xRet

   hb_default( @xDefault, NIL )
   hb_default( @cNameSpace, 'public' )
   
   mh_StartMutex()
   
   HB_HCaseMatch( mh_Hash(), .f. )
   
    if !HB_HHasKey( mh_Hash(), cNameSpace )
		xRet := xDefault 
	else	      
		xRet := hb_HGetDef( mh_Hash()[ cNameSpace ], cKey, xDefault )
	endif 
	
   mh_EndMutex()

RETURN xRet

// ----------------------------------------------------------------//

FUNCTION MH_HashSet( cKey, xValue, cNameSpace )

   hb_default( @cNameSpace, 'public' )   

   mh_StartMutex()
   
   HB_HCaseMatch( mh_Hash(), .f. )
   
   if !HB_HHasKey( mh_Hash(), cNameSpace )		
		mh_Hash()[ cNameSpace ] := {=>} 
   endif 
  
   mh_Hash()[ cNameSpace ][ cKey ] := xValue 
  
   mh_EndMutex()
   
RETURN

// ----------------------------------------------------------------//