function main()

	local cHtml := ''
	
	
	BLOCKS TO cHtml 
	
		<head>
			<title>App Order</title>
			<meta name="viewport" content="width=device-width, initial-scale=1.0">		
		</head>	
	
		<h3>Login</h3>
		<hr>
		
		<form action="access.prg" method="POST">
		
			User name: <input name="user">
			<br>
			Password: <input type="password" name="psw" placeholder="Password is 1234"> 
			<br><br>
			<input type="submit" value="Login">	
			
		</form>
		
	ENDTEXT 
		
	?? cHtml 	

retu nil