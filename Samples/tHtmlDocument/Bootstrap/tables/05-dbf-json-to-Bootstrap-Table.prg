//https://github.com/pbse/JSON-to-Bootstrap-Table
procedure main()

    local cHTML as character

    local oHTMLDoc as object
    local oHeadTitle as object

    cHTML:=hb_MemoRead(hb_GetEnv('PRGPATH')+"/json-to-Bootstrap-Table/example/index-dbf.html")
    oHTMLDoc:=THtmlDocument():New(cHTML)

    oHeadTitle:=oHTMLDoc:Head:title
    oHeadTitle:text:="MOD_HARBOUR :: DBF/JSON to Bootstrap table"

    cHTML:=oHTMLDoc:toString()

    ??cHTML

    return  