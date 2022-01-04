function Main()

	TEMPLATE
	
		Into block

		<br>				
	
		<?prg 
			local cHtml := ''
			
			cHtml += 'Date Today: ' + dtoc( date() )
			cHtml += '<br>'
			cHtml += 'Time now: ' + time()
		
			return cHtml
		?>
		
		<br>
		
		End block		
	
	ENDTEXT 
	
	? 'Bye'

return nil 