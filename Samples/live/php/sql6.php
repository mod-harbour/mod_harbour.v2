<?php 

$mysqli = @new mysqli('localhost', 'harbour', 'password', 'dbHarbour');

	if ($mysqli->connect_errno) {
		die('Connect Error: ' . $mysqli->connect_errno );
	} 

	$cSql = 'select * from customer where age = ' . random_int(20, 90) . ' limit 10';

	echo "<br><b>==> Fetch Query( '" . $cSql . "' )</b><hr>";

	if ( $rs = $mysqli->query( $cSql ) ) {

		while ($row = $rs->fetch_assoc()) {		
			echo '<br>' . $row[ 'first' ] . ' ' . $row[ 'last' ] . ' ' . $row[ 'street' ] . ' ' . $row[ 'city' ] . ' ' . $row[ 'age' ];		
		}

		mysqli_free_result( $rs );	
		
	} else {

		echo $mysqli->error;
	}

mysqli_close($mysqli);

?>