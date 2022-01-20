function main()
   
   Local x 		:= "Harbour"
   local cPhp 	:= ''
   
   BLOCKS TO cPhp PARAMS x   
		<?php
			echo '<h1>Hello {{x}} from PHP!!!<h1>';
			echo '<h3>Time: ' . date('h:i:s') ;
			
		?>   
   ENDTEXT               

    ?? mh_PHPprepro( cPhp )      

return

