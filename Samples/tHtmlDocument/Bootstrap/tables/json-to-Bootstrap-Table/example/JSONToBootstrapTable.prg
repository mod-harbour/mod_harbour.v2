#ifdef __PLATFORM__WINDOWS
   #include "c:\harbour\contrib\hbcURL\hbcURL.ch"
#else
   #include "/usr/include/harbour/hbcURL.ch"
#endif

function Main()

    local aData as array

    local cDbf as character
    local cAlias as character
    local cData as character

    local hData as hash
    local hParam as hash

    hParam:=AP_GetPairs()

    if (!HB_ISNIL(hParam).and.(HB_HHasKey(hParam,"file")))
        switch (hParam["file"])
        case ("dbf")
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
            exit
        case ("json-server")
            cData:=getJsonServerData()
            exit
        case ("json")
            cData:=hb_MemoRead(hb_GetEnv('PRGPATH')+"/JSONToBootstrapTable.json")
            exit
        end switch
    else
        cData:=hb_MemoRead(hb_GetEnv('PRGPATH')+"/JSONToBootstrapTable.json")
    endif

    if (empty(cData))
        TEXT INTO cData
            [
                {"id": 1,"gender": "Male","first_name": "none","last_name": "none","email": "none@ebay.com","ip_address": "65.239.17.202"}, 
                {"id": 2,"gender": "Male","first_name": "none","last_name": "none","email": "none@cbsnews.com","ip_address": "69.21.244.122"}
            ]
        ENDTEXT
    endif

    AP_SetContentType("application/json")

    ?? cData

return

static function getJsonServerData()

    local cURL as character
    local cBuffer as character

    local hcURL as hash

    cURL_global_init()

        if (!empty(hcURL:=cURL_easy_init()))
            //https://github.com/naldodj/naldodj-json-server-multiple-files
            cURL:="http://localhost:3002/db/get/JSONToBootstrapTable.json"
            cURL_easy_setopt(hcURL,HB_CURLOPT_URL,cURL)
            cURL_easy_setopt(hcURL,HB_CURLOPT_SSL_VERIFYPEER,.f.)
            cURL_easy_setopt(hcURL,HB_CURLOPT_SSL_VERIFYHOST,.f.)
            cURL_easy_setopt(hcURL,HB_CURLOPT_NOPROGRESS,.f.)
            cURL_easy_setopt(hcURL,HB_CURLOPT_VERBOSE,.t.)
            cURL_easy_setopt(hcURL,HB_CURLOPT_DL_BUFF_SETUP)
            if (cURL_easy_perform(hcURL)==0)
                cBuffer:=cURL_easy_dl_buff_get(hcURL)
            endif
        endif

    cURL_global_cleanup()

return(cBuffer)
