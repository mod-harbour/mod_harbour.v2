function main()

	local cHtml := ''
	local cUrl 		:= mh_GetUri()
	
	//	Autentication ----------
		
		{% mh_LoadFile( 'autentication.prg' ) %}


	BLOCKS TO cHtml PARAMS cUrl
<html>

	{{ mh_View( 'header.prg', 'Order Process' ) }}
	
	<form action="order.prg" method="POST">
	
	  <label for="cars">Choose a car:</label>
	  <select name="cars" id="cars">
		<option value="volvo">Volvo</option>
		<option value="saab">Saab</option>
		<option value="opel">Opel</option>
		<option value="audi">Audi</option>
	  </select>
	  
	  <br>
	  
	  Qty <input name="qty" value="1">
	  
	  <br><br>
	  <input type="submit" value="Send Order">
	</form>	
	
	<hr>
	
	<a href="{{ cUrl + 'menu.prg' }}" ><button>Menu</button></a>
	<a href="{{ cUrl + 'exit.prg' }}" ><button>Exit</button></a>	  

	
</html>	
	ENDTEXT 
	
	?? cHtml 
	
	
retu nil 
	

