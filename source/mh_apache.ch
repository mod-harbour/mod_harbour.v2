#xcommand ? [<explist,...>] => AP_Echo( '<br>' [,<explist>] )
#xcommand ?? [<explist,...>] => AP_Echo( [<explist>] )

#xcommand BLOCKS TO <b> [ PARAMS [<v1>] [,<vn>] ] [ TAGS <t1>,<t2> ];
=> #pragma __cstream | <b>+=mh_ReplaceBlocks( %s, "{{", "}}" [,<(v1)>][+","+<(vn)>] [, @<v1>][, @<vn>] )

#xcommand DEFAULT <v1> TO <x1> [, <vn> TO <xn> ] ;
=> IF <v1> == NIL ; <v1> := <x1> ; END [; IF <vn> == NIL ; <vn> := <xn> ; END ]

#xcommand DEFAULT <v1> := <x1> [, <vn> TO <xn> ] ;
=> IF <v1> == NIL ; <v1> := <x1> ; END [; IF <vn> == NIL ; <vn> := <xn> ; END ]

#define CRLF 			hb_OsNewLine()

#xcommand TRY  => BEGIN SEQUENCE WITH {| oErr | Break( oErr ) }
#xcommand CATCH [<!oErr!>] => RECOVER [USING <oErr>] <-oErr->
#xcommand FINALLY => ALWAYS