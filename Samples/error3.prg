function main()

	MH_ErrorBlock( {|oError, cCode| MyErrorPlus( oError, cCode ) } )
	
	? a + 5
	
retu nil 

function MyErrorPlus( oError, cCode )

	local hInfo := {=>}
	local cHtml := ''
    local n, aPair 
   
    hInfo[ 'Error' ] := oError:description   

	if ! Empty( oError:operation )
		hInfo[ 'Operation' ] := oError:operation 
	endif   
	
	BLOCKS TO cHtml 

		<style>
		
			body { background-color: lightgray; }
			
			table { box-shadow: 2px 2px 2px black; }
			
			table, th, td {
				border-collapse: collapse;
				padding: 5px;
				font-family: tahoma;
			}
			th, td {
				border-bottom: 1px solid #ddd;
			}			
			th {
			  background-color: #095fa8;
			  color: white;
			}	
			
			tr:hover { background-color: yellow; }
			
			.title {
				width:100%;
				height:70px;
			}
			
			.title_error {
				margin-left: 20px;
				float: left;
				margin-top: 20px;
				font-size: 26px;
				font-family: sans-serif;
				font-weight: bold;
			}
			
			.logo {
				float:left;
				width: 100px;
			}
			
			.description {
				font-weight: bold;
				background-color: #8da5b1;
			}
			
			.value {				
				background-color: white;
			}			
			
		</style>
		
		<!DOCTYPE html>
		<html lang="en">
		<head>
			<meta charset="UTF-8">
			<meta name="viewport" content="width=device-width, initial-scale=1">
			<title>ErrorSys</title>										
			<link rel="shortcut icon" type="image/png" href="images/favicon.ico"/>
		</head>		
		
		<div class="title">
			<img class="logo" src="images/modharbour_mini.png"></img>
			<p class="title_error">Error System</p>			
		</div>
		
		<hr>		
		
		<div>
			<table>
				<tr>
					<th>Description</th>
					<th>Value</th>			
				</tr>	
	ENDTEXT 
	
	
	for n := 1 to len( hInfo )
	
		aPair := HB_HPairAt( hInfo, n)
		
		BLOCKS TO cHtml PARAMS aPair  
		
			<tr>
				<td class="description" >{{ aPair[1] }}</td>
				<td class="value">{{ aPair[2] }}</td>
			</tr>
		
		ENDTEXT 
		
	next 
	
	BLOCKS TO cHtml 

				</table>
			</div>		
		</html>
		
	ENDTEXT 	
	
	?? cHtml 	  

retu nil   
