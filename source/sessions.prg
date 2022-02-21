#include 'hbclass.ch'
#include 'hbclass.ch'
#include 'mh_apache.ch'

#define SESSION_NAME 	 		'MHSESSID'
#define SESSION_PREFIX  		'sess_'
#define SESSION_EXPIRED 		3600


//	------------------------------------------------------------------------------

function mh_SessionInit( cName, nExpired )

	local oSession := MH_Sessions():New( cName, nExpired ) 
	
	oSession:Init()
	
	mh_oSession( oSession )

retu nil

//	------------------------------------------------------------------------------

function mh_Session( cKey, uValue )		//	Setter/Getter

	if ValType( mh_oSession() ) == 'O' .and. mh_oSession():ClassName() == 'MH_SESSIONS'
		retu mh_oSession():Data( cKey, uValue )		
	endif

retu nil

//	------------------------------------------------------------------------------

function mh_SessionWrite()

	if ValType( mh_oSession() ) == 'O' .and. mh_oSession():ClassName() == 'MH_SESSIONS'
		mh_oSession():Write()		
	endif
	
retu nil

//	------------------------------------------------------------------------------

function mh_SessionEnd( cName )

	local oSession 

	
	if ValType( mh_oSession() ) == 'O' .and. mh_oSession():ClassName() == 'MH_SESSIONS'

	else 

		oSession := MH_Sessions():New( cName ) 
	
		oSession:Init()
	
		mh_oSession( oSession )		
	endif	
	
	mh_oSession():End()	

	
retu nil

//	------------------------------------------------------------------------------

function mh_SessionActive( cName )

	local oSession := MH_Sessions():New( cName )


	if oSession:Read_CSID()										
		oSession:Validate()
	endif

	
retu oSession:lIs_Session		

//	------------------------------------------------------------------------------

function mh_Garbage()

	local oSession := MH_Sessions():New() 
	
	oSession:Garbage()		

retu nil


//	------------------------------------------------------------------------------

CLASS MH_Sessions 
	
	DATA cSessionName				INIT SESSION_NAME	
	DATA nExpired					INIT SESSION_EXPIRED
	DATA hSession 					INIT NIL
	DATA cSID 						INIT ''
	DATA lIs_Session				INIT .F.
	DATA lIs_Ready 				INIT .F.
	
	DATA cDirTmp					INIT ''
	DATA cSeed						INIT 'mH_SesSiOn'
	
	CLASSDATA lEnd					INIT .F. 
	

			
	METHOD  New() 					CONSTRUCTOR
	METHOD  Config()
	METHOD  Init()
	
	METHOD  InitData()
	METHOD  SetId()	
	METHOD  IsFile()		
	METHOD  SessionFile()			INLINE if( empty( ::cSID ), '', ::cDirTmp + '/' + SESSION_PREFIX + ::cSID )
	METHOD  Validate()	
	
	METHOD  Data( cKey, uValue )	
	
	METHOD  Read_CSID()
	METHOD  Read()
	METHOD  Write()
	
	METHOD  Info()			
	METHOD  Garbage()			
	METHOD  End()					INLINE ::lEnd := .t. 

ENDCLASS 

//	------------------------------------------------------------------------------

METHOD New( cName, nExpired ) CLASS MH_Sessions

	DEFAULT cName 		TO  ''
	DEFAULT nExpired 	TO SESSION_EXPIRED	

	::cDirTmp 		:= if( AP_GetEnv( 'MH_PATH_SESSION' ) == '' , AP_GetEnv( 'DOCUMENT_ROOT' ) + '/.sessions', AP_GETENV( 'DOCUMENT_ROOT' ) + AP_GETENV( 'MH_PATH_SESSION' )  )
	::cSeed 		:= if( AP_GetEnv( 'MH_SESSION_SEED' ) == '', ::cSeed, AP_GetEnv( 'MH_SESSION_SEED' ) )	
	::cSessionName	:= if( !empty( cName ), Upper(cName) , SESSION_NAME )
	::nExpired 		:= nExpired	
	
	::Config()
	
retu Self

//	------------------------------------------------------------------------------

METHOD Init() CLASS MH_Sessions	
	
	if ::lIs_Ready
		::Read()	
		::lEnd := .f. 
	endif 

retu nil 

//	------------------------------------------------------------------------------

METHOD Config() CLASS MH_Sessions	

	local cFile 
	local lIsDir := .f. 
	
	::lIs_Ready := .f.
	
	//	Init var config global 
		
	if ! hb_HHasKey( mh_HashConfig(), 'sessions' )
		mh_HashConfig()[ 'sessions' ] := .f.
		mh_HashConfig()[ 'sessions_executed' ] := 0
	endif		
	
	if ! mh_HashConfig()[ 'sessions' ] 

		if ! hb_DirExists( ::cDirTmp ) 
		
			hb_DirBuild( ::cDirTmp )
			
		else 
		
			lIsDir = .t. 
		
		endif			
		
		if lIsDir .or. hb_DirExists( ::cDirTmp ) 

			cFile := '__tmp__.txt'
		
			if hb_memowrit( ::cDirTmp + '/' + cFile, 'a' ) 
		
				fErase( ::cDirTmp + '/' + cFile ) 
			
				::lIs_Ready := .t.
				
			endif 
			
		else 
		
			MH_DoError( "Error Sessions. Directory doesn't exist: " + ::cDirTmp  )
			
		endif 
		
		mh_StartMutex()
		 	
		mh_HashConfig()[ 'sessions' ] := ::lIs_Ready 

		mh_EndMutex()
		
	else 
	
		::lIs_Ready := mh_HashConfig()[ 'sessions' ]
		
	endif 		


retu ::lIs_Ready 


//	------------------------------------------------------------------------------

METHOD SetId()  CLASS MH_Sessions
    
    ::cSID := hb_MD5( DToS( Date() ) + Time() + Str( hb_Random(), 15, 12 ) )    

retu nil

//	------------------------------------------------------------------------------

METHOD InitData() CLASS MH_Sessions

	::SetId()

	::hSession := { => }
	
	::hSession[ 'ip'     ] := AP_UserIP()			//	La Ip no es fiable. Pueden usar proxy
	::hSession[ 'sid'    ] := ::cSID
	::hSession[ 'expired'] := seconds() + ::nExpired
	::hSession[ 'data'   ] := { => }

retu nil

//	------------------------------------------------------------------------------

METHOD Data( cKey, uValue )  CLASS MH_Sessions


	if !::lIs_Session
		retu ''
	endif


	if ValType( uValue ) <> 'U' 		//	SETTER

		if !empty( cKey ) 		
			::hSession[ 'data' ][ cKey ] := uValue			
		endif
	
	else								// GETTER

		hb_HCaseMatch( ::hSession, .f. )
		
		if ( hb_HHasKey( ::hSession[ 'data' ], cKey  ) )
			retu ::hSession[ 'data' ][ cKey ] 
		else
			retu ''
		endif
		
	endif

retu nil


//	------------------------------------------------------------------------------

METHOD Read_CSID() CLASS MH_Sessions

	local hGet 		:= AP_GetPairs()
	local lCSID

	::cSID := hb_HGetDef( hGet, ::cSessionName, '' )
	
	if ! empty( ::cSID ) 	//	GET
	
		lCSID 	:= .t.		
			
	else
		
		::cSID 	:= hb_HGetDef( mh_GetCookies(), ::cSessionName, '' )
		
		lCSID 	:= !empty( ::cSID )				
		
	endif

retu lCSID

//	------------------------------------------------------------------------------

METHOD IsFile() CLASS MH_Sessions
	
	local lIsFile := .f.

	::Read_CSID()

	if !empty( ::cSID )
		lIsFile := File( ::SessionFile() )
	endif 

retu lIsFile 

//	------------------------------------------------------------------------------

METHOD Read() CLASS MH_Sessions

	
	local lCSID 	:= .F.
	local cSession, cData

	::lIs_Session := .F.
	
	lCSID := ::Read_CSID()				

	if lCSID 		
		
		::Validate()
	
	endif
	
	if ! ::lIs_Session 
		::InitData()
		::lIs_Session := .t. 
	endif
		
retu nil 

//	------------------------------------------------------------------------------

METHOD Validate() CLASS MH_Sessions

	
	local cSession, cData
	
	::lIs_Session := .f. 

	if File( ::SessionFile() )

	    mh_StartMutex()						

		cSession := hb_Base64Decode( hb_Memoread( ::SessionFile() ) )
		
	    mh_EndMutex()	
	
		//	Si hay contenido Deserializaremos...
		
		if ( !empty( cSession ) )
		
			cData := hb_blowfishDecrypt( hb_blowfishKey( ::cSeed ), cSession )
					

			::hSession := hb_jsondecode( cData )							
			

			if Valtype( ::hSession ) == 'H' 										
			
				//	Validaremos estructura
				
				if ( 	hb_HHasKey( ::hSession, 'ip'   	) .and. ;
						hb_HHasKey( ::hSession, 'sid'  	) .and. ;
						hb_HHasKey( ::hSession, 'expired' ) .and. ;
						hb_HHasKey( ::hSession, 'data' 	) )												
						
					if  ::hSession[ 'expired' ] >= seconds()  .and. ;
						::hSession[ 'ip' ] == AP_USERIP() 
					
						::lIs_Session 	:= .T.					
						
					endif							

				endif	
			
			endif
			
		endif
		
	endif 


RETU ::lIs_Session 


//	------------------------------------------------------------------------------

METHOD Write() CLASS MH_Sessions

	local cSession, cKey, cData, lSave 

	if !::lIs_Session
		retu .f.
	endif	

	if ::lEnd

		
		if ( Valtype( ::hSession ) == 'H'  )
		
			//	Enviaremos la cookie con tiempo expirado. Esto la eliminara y no se volverá a enviar...
			
				mh_Setcookie( ::cSessionName, ::cSID, -1 )
			
			//	Eliminamos Session de disco				
				
				fErase( ::SessionFile() )
				
		endif
		
		//	Eliminamos variable GLOBAL de Session
		
			::hSession  	:= NIL
			::cSID			:= ''
			::lIs_Session	:= .F.	
		
	else 	

		::hSession[ 'sid'    ] 	:= ::cSID
		::hSession[ 'expired' ] 	:= seconds() + SESSION_EXPIRED	
		
		cSession 	:= hb_jsonencode( ::hSession )

		cKey 		:= hb_blowfishKey( ::cSeed )	
		cData 		:= hb_blowfishEncrypt( cKey, cSession )					

	    mh_StartMutex()
				
		lSave := hb_memowrit( ::SessionFile(), hb_Base64Encode( cData ) ) 	

		mh_HashConfig()[ 'sessions_executed' ]++ 
		
	    mh_EndMutex()
		
		mh_Setcookie( ::cSessionName, ::cSID, ::nExpired )				
		
		if mh_HashConfig()[ 'sessions_executed' ] > 1000	// Add var env. ? p.e. MH_SESSION_MAX_FILES ? 
			::Garbage()
			 mh_StartMutex()
			 mh_HashConfig()[ 'sessions_executed' ] := 0
			 mh_EndMutex()
		endif		

	endif
	
retu nil

//	------------------------------------------------------------------------------
//	Delete files <= dMaxDate. Default 1 day ago

METHOD Info() CLASS MH_Sessions

	local aFiles 	:= Directory( ::cDirTmp + '*.*' )
	local nFiles 	:= len( aFiles )
	local nBytes 	:= 0 
	local nI
	local hInfo 	:= {=>}
	
	for nI := 1 to nFiles
	
		nBytes += aFiles[nI][2]

	next
	
	hInfo[ 'files' ] 	:= nFiles
	hInfo[ 'bytes' ] 	:= nBytes

retu hInfo

//	------------------------------------------------------------------------------
//	Delete files <= dMaxDate. Default 1 day ago

METHOD Garbage( dMaxDate ) CLASS MH_Sessions

	local aFiles 	:= Directory( ::cDirTmp + '/*.*' )
	local nFiles 	:= len( aFiles )
	local nI 

	DEFAULT dMaxDate TO Date()-2
	
	for nI := 1 to nFiles 
	
		if aFiles[nI][3] <= dMaxDate 				
			fErase( ::cDirTmp + '/' + aFiles[nI][1] )			
		endif
	next	
	
retu nil

//	------------------------------------------------------------------------------
