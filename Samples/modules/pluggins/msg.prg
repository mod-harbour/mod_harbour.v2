function Msg( u )
	
	local cHtml := ''
	
	BLOCKS TO cHtml PARAMS u
	
		<style>
			.mymsg {
				padding:10px;
				background-color:green;
				box-shadow: 4px 4px 4px black;
				margin-top: 50px;
				margin-bottom: 50px;
				color: yellow;
				font-family: tahoma;
				font-size: 18px;				
			}
		</style>
	
		<div class="mymsg">
			{{ mh_valtochar( u ) }}
		</div>
	
	ENDTEXT 
	
	?? cHtml

retu nil 