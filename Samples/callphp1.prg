#xcommand TEMPLATE [ USING <x> ] [ PARAMS [<v1>] [,<vn>] ] ;
=> #pragma __cstream | ap_Echo( mh_PHPprepro( %s, [@<x>] [,<(v1)>][+","+<(vn)>] [, @<v1>][, @<vn>] ) )

function main()

   TEMPLATE
     <?php phpinfo(); ?>
   ENDTEXT      

return

