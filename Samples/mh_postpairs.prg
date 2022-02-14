function main()
	
   ? 'Body:' , AP_Body()   
   ? 'Method:', Ap_Method()
   ? 'Args:', Ap_Args()
   
   if AP_Method() == "POST"
   
		? Ap_PostPairs()

   else   
      ? "This example is used to review POST sent values"
   endif

return nil
