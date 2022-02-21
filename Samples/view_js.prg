function main()

	local cHtml := ''

	
    BLOCKS TO cHtml
      
		{{ mh_View( 'v_bootstrap.view', 'MyApp' ) }}
		{{ mh_Js( 'v_js_a.js' ) }}
	  
		<div class="container">
		
			<h4>Hello...</h4><hr>
		   
			<button type="button" onclick="MyFunc()" class="btn btn-warning">Test</button>

		</div>
		
    ENDTEXT
	
	?? cHtml 


retu nil 