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
	LOCAl cSql 	:= 'select * from customer where age = ' + str(int(hb_Random( 20, 90 ))) + ' limit 10'
	
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
			? hRs[ 'first' ], hRs[ 'last' ], hRs[ 'street' ], hRs[ 'city' ], hRs[ 'age' ]
		END
	
	ENDIF	
		
RETU NIL