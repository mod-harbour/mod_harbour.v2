#xcommand PHP <v> => ap_Echo( mh_PHPprepro( <v> ) )


function main()

   Local a := "<?php echo '<h1>Hello from PHP 1!!!<h1>'; ?>"   
   Local b := "<?php echo '<h1>Hello from PHP 2!!!<h1>'; ?>"   
   
   PHP a
   PHP b

return

