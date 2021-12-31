//----------------------------------------------------------------//

function Main()
	
   ?? "<h2>Creating a cookie</h2>"      

   SetCookie( 'MyCookieName', 'This cookie was created at ' + Time() + ;
              '. In this example it only lives 60 seconds...', 60 )
	
   ? 'cookie created!'
   ?
   ? '<button type="button" onclick="location.href=' + "'getcookie.prg'" + '">get cookie</button>'

return nil

//----------------------------------------------------------------//
