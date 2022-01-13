/* Only for develop	*/

//_d(...)	--> to Debug DbWin32
//_w(...)	--> to web 
//_l(...)	--> to log file 

#include "FileIO.ch"
#include "mh_apache.ch"

//	--------------------------------------------------------- //

function _d( ... )

retu WAPI_OutputDebugString( MH_Out( 'dbg', ... ) )

//	--------------------------------------------------------- //

function _w( ... )

	?  '<code>' + MH_Out( 'web', ... ) + '</code>'
	
retu nil

//	--------------------------------------------------------- //

function _l( ... )

	local cFile 	:= MH_Log_File()[1]	
	local cPath 	:= hb_FNameDir( cFile ) 	//cFilePath( cFile )
	local cLine	:= ''
	local hFile
	
	//	Check directory 
	
		cPath := strtran( cPath, '/', '\')
	
		if ! hb_DirExists( cPath ) 
		
			hb_DirBuild( cPath )
			
			if ! hb_DirExists( cPath ) 							
				retu .f.
			endif 	
			
		endif
		
	//	Check file

		if PCount() == 0
			if  fErase( cFile ) == -1
				//	? 'Error eliminando ' + cFilename, fError()
			endif
			retu .f. 
		endif

		if ! File( cFile )
			fClose( FCreate( cFile ) )	
		endif
		
	//	Create log

		if ( ( hFile := FOpen( cFile, FO_WRITE ) ) == -1 )	
			retu .f.
		endif
		
		cLine +=  MH_Out( 'log', ... )
			
		fSeek( hFile, 0, FS_END )
		fWrite( hFile, cLine, Len( cLine ) )		

		fClose( hFile )   

retu .t.

//	--------------------------------------------------------- //

static function MH_Out( cOut, ... )

    local cLine	:= ''
	local lTime 	:= MH_Log_File()[2]
   	local nParam 	:= PCount()
	local nI, cBreak, cSep, oError 

	DEFAULT cOut := 'web' 
	
	do case
		case cOut == 'web' 
		
			cBreak := '<br>'
			cSep  	:= '&nbsp;'
			
		case cOut == 'log' 
		
			cBreak := CRLF 
			cSep 	:= ' ' 
			
		case cOut == 'dbg' 
		
			cBreak := CRLF 
			cSep 	:= ' ' 		
	endcase		
	
	for nI := 2 to nParam
	
		if lTime .and. cOut == 'log'
			cLine += DToC( date()) + ' ' + time() + ' '		
		endif 			

		cLine  	+= 'Type (' + valtype( pValue(nI) ) + ') ' + MH_ValTo( cOut, pValue(nI) ) + cBreak
		
	next	

retu cLine

//	--------------------------------------------------------- //

function MH_Log_File( cFileLog, lSetTime )

	thread static cFile
	thread static lTime  := .t.
	
	DEFAULT cFileLog 	:=  ''
	
	if cFile == NIL 		
		cFile := if( AP_GETENV( 'MH_PATH_LOG' ) == '' , HB_GetEnv( 'PRGPATH' ) + '/log.txt', AP_GETENV( 'DOCUMENT_ROOT' ) + AP_GETENV( 'MH_PATH_LOG' ) + '/log.txt' )
	endif 
	
	if !empty( cFileLog )
		cFile := cFileLog 
	endif	
	
	if valtype( lSetTime ) == 'L'
		lTime := lSettime 
	endif		

retu { cFile, lTime }

//	--------------------------------------------------------- //

static function MH_ValTo( cOut, u, nTab )

	local cType := ValType( u )
	local cResult
	local n, nLen, aPair, hValue
	
	DEFAULT cOut := 'web' 
	DEFAULT nTab :=  0
	
	nTab++
	
	
	do case
		case cType == "C" .or. cType == "M"
			cResult = u
	
		case cType == "D"		; cResult = DToC( u )
		case cType == "L" 		; cResult = If( u, ".T.", ".F." )
		case cType == "N"		; cResult = AllTrim( Str( u ) )	  
		case cType == "A"		; cResult := MH_HashArrayTo( cOut, @nTab, u )
			
		case cType == "O"		
		
			hValue		:= MH_ObjToHash(u)		
			cResult 	:= MH_HashArrayTo( cOut, @nTab, hValue )
			
		case cType == "P"   	; cResult := hb_NumToHex( u )  
		case cType == "S"		; cResult := "(Symbol)"  
		case cType == "H"		; cResult := MH_HashArrayTo( cOut, @nTab, u )   
		case cType == "U"		; cResult := "nil"
		
		otherwise
			cResult = "type not supported yet in function MH_ValTo()"
	endcase
 

retu cResult 

//	--------------------------------------------------------- //

static function MH_HashArrayTo( cOut, nTab, u )	

	local cResult 	:= ''
	local cType 	:= valtype( u)
	local nLen 	:= len( u )	
	local uValue 
	local n, aPair, cSep, cBreak 
	
	//nTab++
	
	do case
		case cOut == 'web' 
		
			cBreak	:= '<br>'
			cSep 	:= '&nbsp;'
			
		case cOut == 'log' 
		
			cBreak	:= CRLF 
			cSep 	:= ' ' 
			
		otherwise 
		
			cBreak	:= CRLF 
			cSep 	:= ' ' 		
	endcase		

	if nLen > 0 
	
		cResult := '{' + cBreak  
	
		for n := 1 to nLen			

			do case 
				case cType == 'H'		
					
					aPair := HB_HPairAt( u, n )					
					
					cResult += Replicate( cSep, nTab * 3 ) + 'Key: ' + aPair[1]  + ' (' + valtype(aPair[2]) + ') => ' + MH_ValTo( cOut, aPair[2], nTab ) + cBreak
				
				case cType == 'A'

					cResult += Replicate( cSep, nTab * 3 ) + 'Type (' + valtype( u[n] ) + ') ' + MH_ValTo( cOut, u[n], nTab ) + cBreak 
			endcase

		next 
		
		cResult += Replicate( cSep, --nTab * 3 ) + '}'	
		
	else 
	
		if cType == 'H'
			cResult := '{=>}'
		else 
			cResult := '{}'
		endif	
	
	endif

retu cResult

//	--------------------------------------------------------- //

static function MH_ObjToHash( o )

	local hObj 	:= {=>}
	local hPairs 	:= {=>} 
	local oError 
	local aDatas, aParents 
	
	try 
	
		aDatas 	:= __objGetMsgList( o, .T. )
		aParents 	:= __ClsGetAncestors( o:ClassH )
	
		AEval( aParents, { | h, n | aParents[ n ] := __ClassName( h ) } ) 
	
		hObj[ "CLASS" ] := o:ClassName()
		hObj[ "FROM" ]  := aParents 
	
		AEval( aDatas, { | cData | hPairs[ cData ] := __ObjSendMsg( o, cData ) } )
		
		hObj[ "DATAs" ]   := hPairs
		hObj[ "METHODs" ] := __objGetMsgList( o, .F. )
	
	catch oError 
	
		hObj[ 'error'] := 'Error MH_ObjToHash'		
		
	end 

retu hObj

//	--------------------------------------------------------- //