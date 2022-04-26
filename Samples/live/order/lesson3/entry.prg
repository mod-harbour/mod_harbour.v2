function main()

	local cHtml := ''
	local cUrl 		:= mh_GetUri()
	
	//	Autentication ----------
		
		{% mh_LoadFile( 'autentication.prg' ) %}
		

	BLOCKS TO cHtml 
	
		{{ mh_View( 'header.view' ) }}	
		
		<body>
		
	ENDTEXT  		

	cHtml += MyNav( 'Create Order', {	;					
						{ 'Menu', 'menu.prg' },;
						{ 'Exit', 'exit.prg'};
					}) 	

					
	BLOCKS TO cHtml 
	
		<div class="content" >
			<div class="d-flex justify-content-center row p-5" align="center">			
			
				<form action="order.prg" method="POST" onsubmit="return confirm('Are you sure ?');">
				
					<div class="form-group row text-right">
					  <label for="cars" class="col-6 col-form-label">Choose a car</label><br>
					  <div class="col-6">
						  <select class="form-control" name="cars" id="cars">
							<option value="volvo">Volvo</option>
							<option value="saab">Saab</option>
							<option value="opel">Opel</option>
							<option value="audi">Audi</option>
						  </select>
					  </div>
					</div>
				  
					<br>
				  
					<div class="form-group row text-right">
						<label for="qty" class="col-6 col-form-label">Quantity</label><br>
						<div class="col-6">
							<input type="number" class="form-control text-center" name="qty" id="qty" value="1">
						</div>
					</div>

					<br><br>
					
					<input class="btn btn-primary"  type="submit" value="Send Order">
					
				</form>	
			</div>		
		</div>		
			
		</body>
		</html>	
	ENDTEXT 
	
	?? cHtml 	
	
retu nil 

//	--------------------------------------------------------	//

{% mh_LoadFile( 'public.prg' ) %}
	

