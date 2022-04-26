function main()

	local cHtml := ''
	
	
	BLOCKS TO cHtml 
	
		{{ mh_View( 'header.view' ) }}		

		<body>
		
			<nav class="navbar navbar-dark bg-dark">
			  <a class="navbar-brand" href="#">Login</a>
			</nav>			
			
			<div class="d-flex row justify-content-center p-5" align="center">
				<form action="access.prg" method="POST">
					<div class="mb-3">
						<label for="user">User Name</label><br>
						<input class="form-control" name="user" id="user">
					</div>
					
					<br>
						
					<div class="mb-3">
						<label for="psw">Password</label><br>
						<input class="form-control" type="password" name="psw" id="psw" placeholder="Password is 1234"> 
					</div>
					
					<br><br>
					
					<input class="btn btn-primary" type="submit" value="Login">	
					
				</form>
			</div>
			
		</body>
		</html>
	ENDTEXT 
		
	?? cHtml 	

retu nil