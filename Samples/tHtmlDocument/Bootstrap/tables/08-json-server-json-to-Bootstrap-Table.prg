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
    oHeadTitle:text:="MOD_HARBOUR :: JSON-SERVER/JSON to Bootstrap table"
    
    oDivContainer:=oHTMLDoc:body:div
    oDivContainer:attr:='class="container"'
    
    oDivPageHeader:=oDivContainer+"div"
    oDivPageHeader:attr:='class="page-header"'
    oDivPageHeaderH2:=oDivPageHeader:h2
    oDivPageHeaderH2:text:="mod_harbour :: JSON-SERVER/JSON to Bootstrap table"
    
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
    url:'./json-to-Bootstrap-Table/example/JSONToBootstrapTable.prg?file=json-server',
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

        oFigureHighlightPreH4:=oFigureHighlightPre+"h4"
        oFigureHighlightPreH4:text:="JSON-SERVER"

        oFigureHighlightPreCode:=oFigureHighlightPre+"code"
        TEXT INTO oFigureHighlightPreCode:text
# 🚤 json-server-multiple-files

Using json-server to server multiple json files in less than *45 seconds* (trust me).

https://github.com/naldodj/naldodj-json-server-multiple-files

## Prequisite
- nodemon `sudo npm install -g nodemon`

## Getting Started
1. Place your .json files into the `db` folder (⚠️ make sure they match the format)
2. Install dependencies with `npm install`
3. Run the server : `npm run start:server`

## Output
````
[nodemon] 1.18.10
[nodemon] to restart at any time, enter `rs`
[nodemon] watching: test/mock
[nodemon] starting `node json-server.index.js`


🗒    JSON file loaded : places.json
🗒    JSON file loaded : teams.json

⛴    JSON Server is running at http://localhost:3002
🥁    Endpoint : http://localhost:3002/organisations
🥁    Endpoint : http://localhost:3002/tenders
````

## Todo
- Check the json format, and remove json that does not match.

## Built With
- [typicode/json-server](https://github.com/typicode/json-server)

## License
MIT
        ENDTEXT

    oFigureHighlight:=oDivPageHeaderRowDiv:AddNode(THtmlNode():New(oDivPageHeaderRowDiv,"/figure"))
    
    oScript:=oHTMLDoc:body+"script"
    oScript:src:="./json-to-Bootstrap-Table/example/jsonToTable.min.js"

    oScript:=oHTMLDoc:body+"script"
    TEXT INTO oScript:text
var dtbl=new createTable(
    {
        url:'./json-to-Bootstrap-Table/example/JSONToBootstrapTable.prg?file=json-server',
        wrapper:".createTableJSON"
    }
).create();
    ENDTEXT

    cHTML:=oHTMLDoc:toString()

    ??cHTML

    return