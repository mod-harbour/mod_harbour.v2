//	--------------------------------------------------------------
//	Title......: WDO Web Database Objects
//	Description: Test WDO
//	Date.......: 28/07/2019
//
//	{% MH_LoadHRB( 'lib/wdo.hrb' ) %}							//	Loading WDO lib
//	{% HB_SetEnv( 'WDO_PATH_MYSQL', "c:/xampp/htdocs/" ) %}		//	Usuarios Xampp
//	--------------------------------------------------------------

FUNCTION Main()

	LOCAL o, oRs, n, j
	LOCAl cSql 	:= 'SHOW STATUS WHERE variable_name LIKE "Threads_%" OR variable_name = "Connections"'
	
    IF mh_HashGet( 'oMySql' ) != NIL

		o := mh_HashGet( 'oMySql' )
				
    ELSE	
		
		o := WDO():Rdbms( 'MYSQL', "localhost", "harbour", "password", "dbHarbour", 3306 )
		
		IF ! o:lConnect		
			RETU NIL
		ENDIF
		
		mh_HashSet( 'oMySql', o )	
		
    ENDIF	

	? "<b>==> Fetch  Query( '" + cSql + "' )</b><hr>"
	
	IF !empty( hRes := o:Query( cSql ) )		
	
		WHILE ( !empty( hRs := o:Fetch_Assoc( hRes ) ) )			
			? hRs[ 'Variable_name'], hRs[ 'Value' ]
		END
		
	ELSE 
	
		? 'Error: ', o:mysql_error()
		
		o := WDO():Rdbms( 'MYSQL', "localhost", "harbour", "password", "dbHarbour", 3306 )
		
		? 'Reconnecting...'
		
		IF ! o:lConnect		
			?? 'KO'
			RETU NIL
		ENDIF
		
		?? 'Done !'
		
		mh_HashSet( 'oMySql', o )			
	
	ENDIF	
		
RETU NIL