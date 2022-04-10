function Main()

    local aData as array
    
    local cDbf as character
    local cAlias as character
	local cData as character

    local hData as hash
    local hParam as hash
    
    hParam:=AP_GetPairs()
    
    if (!HB_ISNIL(hParam).and.(HB_HHasKey(hParam,"file")))
        if (hParam["file"]=="dbf")
            cDbf:=hb_getenv('PRGPATH')+'/../../data/json.dbf'
            use (cDbf) shared new 
            cAlias:=alias()  
            aData:=array(0)
            (cAlias)->(dbGoTop())
            while ((cAlias)->(!eof()))
                cData:=(cAlias)->JSON
                hData:=hb_JsonDecode(cData)
                aAdd(aData,hData)
                (cAlias)->(dbSkip())
            end while
            cData:=hb_jsonEncode(aData,.T.)
        elseif (hParam["file"]=="json")
            cData:=hb_MemoRead(hb_GetEnv('PRGPATH')+"/example.json")
        endif
    else
        cData:=hb_MemoRead(hb_GetEnv('PRGPATH')+"/example.json")
    endif    
    
    AP_SetContentType( "application/json" )

	?? cData
    
return    