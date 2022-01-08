//	--------------------------------------------------------------
//	Title......: WDO Web Database Objects
//	Description: Test WDO
//	Date.......: 28/07/2019
//
//	{% MH_LoadHRB( 'lib/wdo.hrb' ) %}						//	Loading WDO lib
//	{% HB_SetEnv( 'WDO_PATH_MYSQL', "c:/xampp/htdocs/" ) %}	//	Usuarios Xampp
//	--------------------------------------------------------------

FUNCTION Main()

	LOCAL o			
		
		o := WDO():Rdbms( 'MYSQL', "localhost", "harbour", "password", "dbHarbour", 3306 )
		
		IF o:lConnect
		
			? 'Connected !', '<b>Version RDBMS MySql', o:Version()
			
		ELSE
		
			? '<b>Error</b>', o:cError 
			
		ENDIF								

RETU NIL
