/*
**  ap_func.prg -- Apache API in wrappers
**
*/


THREAD STATIC ts_Body 

function AP_BODY()
   
   if ts_Body == NIL         
      ts_Body = ap_GetBody()
   endif

retu ts_Body
