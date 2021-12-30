function main()
    
    local cTime 	:= time()
	local cHtml 	:= ''

    BLOCKS TO cHtml PARAMS cTime 
		<!DOCTYPE html>
		<html lang="en">
		<head>
			<meta charset="UTF-8">
			<meta name="viewport" content="width=device-width, initial-scale=1">
			<title>Test bootstrap</title>
			<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js"></script>
			<link rel="stylesheet" type="text/css" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.1.3/css/bootstrap.css"/>
		</head>
		<body>
		<div class="container">
		   <h4>Login into system: {{ cTime }}</h4><hr>
		   
  			<div class="row justify-content-center p-5">

    			<div class="d-flex">
				
				<form action="postpairs.prg" method='POST'>
					<div class="mb-3">
					  <label for="exampleFormControlInput1" class="form-label">User name</label>
					  <input type="text" class="form-control" id="exampleFormControlInput1" name="username" placeholder="Enter user name...">
					</div>
					<div class="mb-3">
					  <label for="exampleFormControlInput2" class="form-label">Password</label>
					  <input type="password" class="form-control" id="exampleFormControlInput2" name="passw" placeholder="Enter password...">
					</div>
					<div class="col text-center">
						<button type="submit" class="btn btn-success" >Accept</button>
					</div>
				</form>
				
				</div>
			</div>
		</div>
		</body>
		</html>
    ENDTEXT		
	
	
	?? cHtml

return nil