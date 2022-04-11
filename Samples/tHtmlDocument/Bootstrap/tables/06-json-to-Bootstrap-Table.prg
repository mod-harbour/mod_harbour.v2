//https://github.com/pbse/JSON-to-Bootstrap-Table
procedure main()

    local cHTML as character

    local oScript as object
    local oHTMLDoc as object
    
    local oHeadTitle as object
    
    local oDivContainer as object
    
    local oDivPageHeader as object  
    local oDivPageHeaderH2 as object 
    local oDivPageHeaderRow as object 
    local oDivPageHeaderRowH4 as object  
    local oDivPageHeaderRowDiv as object 
    
    local oDivCreateTableJSON as object
    
    local oFigureHighlight as object
    local oFigureHighlightPre as object
    local oFigureHighlightPreH4 as object 
    local oFigureHighlightPreCode as object

    cHTML:=hb_MemoRead(hb_GetEnv('PRGPATH')+"/json-to-Bootstrap-Table/example/index-json-dbf.html")
    oHTMLDoc:=THtmlDocument():New(cHTML)

    oHeadTitle:=oHTMLDoc:Head:title
    oHeadTitle:text:="MOD_HARBOUR :: JSON/JSON to Bootstrap table"
    
    oDivContainer:=oHTMLDoc:body:div
    oDivContainer:attr:='class="container"'
    
    oDivPageHeader:=oDivContainer+"div"
    oDivPageHeader:attr:='class="page-header"'
    oDivPageHeaderH2:=oDivPageHeader:h2
    oDivPageHeaderH2:text:="mod_harbour :: JSON/JSON to Bootstrap table"
    
    oDivPageHeaderRow:=oDivContainer+"div"
    oDivPageHeaderRow:attr:='class="row"'
    
    oDivPageHeaderRowH4:=oDivPageHeaderRow:h4
    oDivPageHeaderRowH4:text:="mod_harbour :: Bootstrap Table with JSON Data - Ajax request"
    
    oDivPageHeaderRowDiv:=oDivPageHeaderRow+"div"
    oDivCreateTableJSON:=oDivPageHeaderRowDiv+"div"
    oDivCreateTableJSON:attr:='class="createTableJSON"'
    
    oFigureHighlight:=oDivPageHeaderRowDiv:AddNode(THtmlNode():New(oDivPageHeaderRowDiv,"figure"))
        oFigureHighlight:attr:='class="highlight"'
        
        oFigureHighlightPre:=oFigureHighlight+"pre"
        oFigureHighlightPreH4:=oFigureHighlightPre+"h4"
        oFigureHighlightPreH4:text:="Code Used"
        
        oFigureHighlightPreCode:=oFigureHighlightPre+"code"
        
        TEXT INTO oFigureHighlightPreCode:text
&lt;script src="./json-to-Bootstrap-Table/example/jsonToTable.js"&gt;&lt;/script&gt;
&lt;script&gt;
    var dtbl = new createTable({
    url:'./json-to-Bootstrap-Table/example/JSONToBootstrapTable.prg?file=json',
    wrapper:".createTableJSON"
    }).create();
&lt;/script&gt;
        ENDTEXT

        oFigureHighlightPreH4:=oFigureHighlightPre+"h4"
        oFigureHighlightPreH4:text:="To Pass a Data instead of URL"
        
        oFigureHighlightPreCode:=oFigureHighlightPre+"code"
        TEXT INTO oFigureHighlightPreCode:text
&lt;script src="./json-to-Bootstrap-Table/example/jsonToTable.js"&gt;&lt;/script&gt;
&lt;script&gt;
    var ctbl = new createTable({
    data:[{"d":"a", "e":"b"},{"e":"a", "d":"b"}],
    wrapper:".createTable"
    }).create();
&lt;/script&gt;
        ENDTEXT

        oFigureHighlightPreH4:=oFigureHighlightPre+"h4"
        oFigureHighlightPreH4:text:="JSON Data"

        oFigureHighlightPreCode:=oFigureHighlightPre+"code"
        TEXT INTO oFigureHighlightPreCode:text
[
    {"id": 1,"gender": "Male","first_name": "Randy","last_name": "Russell","email": "rrussell0@ebay.com","ip_address": "65.239.17.202"}, 
    {"id": 2,"gender": "Male","first_name": "Mark","last_name": "Ryan","email": "mryan1@cbsnews.com","ip_address": "69.21.244.122"}.... & more
]
        ENDTEXT

    oFigureHighlight:=oDivPageHeaderRowDiv:AddNode(THtmlNode():New(oDivPageHeaderRowDiv,"/figure"))
    
    oScript:=oHTMLDoc:body+"script"
    oScript:src:="./json-to-Bootstrap-Table/example/jsonToTable.min.js"

    oScript:=oHTMLDoc:body+"script"
    TEXT INTO oScript:text
var dtbl=new createTable(
    {
        url:'./json-to-Bootstrap-Table/example/JSONToBootstrapTable.prg?file=json',
        wrapper:".createTableJSON"
    }
).create();
    ENDTEXT

    cHTML:=oHTMLDoc:toString()

    ??cHTML

    return