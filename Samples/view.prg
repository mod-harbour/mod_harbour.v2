function main()

	local cHtml := ''

	
    BLOCKS TO cHtml
      
		{{ mh_View( 'v_bootstrap.view', 'MyApp' ) }}
	  
		<div class="container">
		
		   <h4>Hello...</h4><hr>

		</div>
		
    ENDTEXT
	
	?? cHtml 


retu nil 