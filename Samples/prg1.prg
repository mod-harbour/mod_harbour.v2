function Main()

	TEMPLATE
	
		Into block

		<br>
		
		Date today: 
	
		<?prg 
			local cDate := dtoc( date() )
		
			return cDate
		?>
		
		<br>
		
		End block		
	
	ENDTEXT 
	
	? 'Bye'

return nil 