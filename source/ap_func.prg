/*
**  ap_func.prg -- Apache API in wrappers
**
*/


THREAD STATIC HWBody 

function AP_BODY()
   
   if HWBody == NIL         
      HWBody = AP_GetBody()
   endif

retu HWBody
