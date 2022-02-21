function main()

	local cHtml := ''

	
    BLOCKS TO cHtml
      
		{{ mh_View( 'v_bootstrap.view', 'MyApp' ) }}
		{{ mh_Css( 'v_css_a.css' ) }}
	  
		<div class="container">
		
		   <h4>Hello...</h4><hr>
		   
		   <div class="mypanel">
				Css test...
		   </div>

		</div>
		
    ENDTEXT
	
	?? cHtml 


retu nil 