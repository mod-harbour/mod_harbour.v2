#ifdef __PLATFORM__WINDOWS
   #include "c:\harbour\include\dbstruct.ch"
#else
   #include "/usr/include/harbour/dbstruct.ch"
#endif

procedure main()

    local aDbStruct as array
    
    local cDbf as character 
    local cHTML as character
    local cTitle as character
    local cAlias as character 

    local oRow as object
    local oDiv as object
    local oNode as object
    local oCell as object
    local oTable as object
    local oThead as object
    local oTBody as object
    local oHTMLDoc as object
    
    local nField as numeric
    local nFields as numeric
    
    local xValue

    cDbf:=hb_getenv('PRGPATH')+'/data/users.dbf'
    use (cDbf) shared new 
 
    cAlias:=alias()  

    cHTML:=BS_StarterTemplate()
    oHTMLDoc:=THtmlDocument():New(cHTML)
    
    cTitle:="mod_harbour :: Bootstrap :: Tables :: table-hover"

    /* Operator "+" creates a new node */
    oNode:=oHTMLDoc:head+"meta"
    oNode:name:="Generator"
    oNode:content:="THtmlDocument"
    
    oNode:=oHTMLDoc:head+"title"
    oNode:text:=cTitle

    /* Operator ":" returns first "div" from body (creates if not existent) */
    oDiv:=oHTMLDoc:body:div
    oDiv:attr:='class="container"'

    /* Operator ":" returns first "h1" from div (creates if not existent) */
    oNode:=oDiv:h1
    oNode:text:=cTitle

    /* Operator ":" returns first "hr" from div (creates if not existent) */
    oNode:=oDiv:hr

    /* Operator "+" creates a new <p> node */
    oNode:=oDiv+"p"

    /* Operator "+" creates a new <font> node with attribute */
    oNode+='font size="5"'
    oNode:text:="This is a "

    /* Operator "+" creates a new <b> node */
    oNode+="b"

    /* Operator "+" creates a new <font> node with attribute */
    oNode+='font color="blue"'
    oNode:text:="sample "

    /* Operator "-" closes 2nd <font>,result is <b> node */
    oNode-="font"

    /* Operator "-" closes <b> node,result is 1st <font> node */
    oNode-="b"

    oNode:text:="Bootstrap Table :: table-hover!"

    /* Operator "-" closes 1st <font> node,result is <p> node */
    oNode-="font"

    oNode+="hr"
    
    /* Operator ":" returns first "table" from div (creates if not existent) */
    oTable:=oDiv:table
    oTable:attr:='class="table table-hover"'
    
    oThead:=oTable:AddNode(THtmlNode():New(oTable,"thead"))
    
        oRow:=oThead:AddNode(THtmlNode():New(oThead,"tr"))
        
        oCell:=oRow:AddNode(THtmlNode():New(oRow,"th"))
        oCell:scope:="row"
        oCell:text:="#"
        oCell:=oCell-"th"
        
        nFields:=(cAlias)->(fCount())
        for nField:=1 to nFields
            oCell:=oRow:AddNode(THtmlNode():New(oRow,"th"))
            oCell:scope:="col"
            oCell:text:=(cAlias)->(FieldName(nField))
            oCell:=oCell-"th"
        next nField
        
        oRow:=oRow-"tr"
    
    oThead:=oTable:AddNode(THtmlNode():New(oTable,"/thead"))
    
    oTBody:=oTable:AddNode(THtmlNode():New(oTable,"tbody"))

        aDbStruct:=(cAlias)->(dbStruct())
        (cAlias)->(dbGoTop())
        while (cAlias)->(!eof())
            oRow:=oTBody:AddNode(THtmlNode():New(oTBody,"tr"))
            oCell:=oRow:AddNode(THtmlNode():New(oRow,"th"))
            oCell:scope:="row"
            oCell:text:=(cAlias)->(RecNo())
            oCell:=oCell-"th"
            for nField:=1 to (cAlias)->(fCount())
                oCell:=oRow:AddNode(THtmlNode():New(oRow,"td"))
                xValue:=(cAlias)->(FieldGet(nField))
                if (aDbStruct[nField][DBS_TYPE]=="C")
                    xValue:=allTrim(xValue)
                endif
                oCell:text:=xValue
                oCell:=oCell-"td"
            next nField
            oRow:=oRow-"tr"
            (cAlias)->(dbSkip())
        end while
    
    oTBody:=oTable:AddNode(THtmlNode():New(oTable,"/tbody"))
    
    oNode:=oTable:caption
    oNode:text:=hb_NTos((cAlias)->(RecCount()))+" records from database "+cAlias
    
    (cAlias)->(dbCloseArea())

    cHTML:=oHTMLDoc:toString()

    ??cHTML

    return
    
{% MH_LoadFile( '..\pluggins\templates\BS_StarterTemplate.prg') %}    
