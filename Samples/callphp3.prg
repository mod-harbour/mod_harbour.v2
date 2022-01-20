#xcommand BLOCKS [ PARAMS [<v1>] [,<vn>] ] ;
=> #pragma __cstream | ap_Echo( mh_PHPprepro( mh_ReplaceBlocks( %s, "{{", "}}" [,<(v1)>][+","+<(vn)>] [, @<v1>][, @<vn>] ) ))

function main()
   
   Local x:= "Harbour"
   
   BLOCKS PARAMS x
      <?php 

         echo '<h1>Hello {{x}} from PHP!!!<h1>';

      ?>
   ENDTEXT

return

