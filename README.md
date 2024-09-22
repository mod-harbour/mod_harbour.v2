# mod_harbour.v2.1
mod_harbour.v2.1 - Harbour Apache Module 


➜ [**Wiki - Installation**](https://github.com/mod-harbour/mod_harbour.v2/wiki/Installation)

Apache 參數設定
加入下面設定值於 ./conf/httpd.conf

    <FilesMatch "\.(prg|hrb|view)$">
        SetHandler harbour
    </FilesMatch>

**Windows OS:

    LoadModule mod_harbourV2_module modules/mod_harbour.v2.so
    MH_LIBRARY c:\\xampp\\apache\\bin\\libmhapache.dll
    MH_NVMS 10

依照檔案: libmhapache.dll 放置 apache 目錄做設定. 通常是放在 ./bin/ 裡面.

MH_NVMS: 代表一開機要開啟幾個多緒等待呼叫? 預設值為 10，將會在 apache 啟動後於系統暫存目錄下看到建立檔案的檔案，方別為 libmhapache0.dll、libmhapache1.dll ... libmhapache9.dll

**Linux OS:

    LoadModule mod_harbourV2_module /usr/lib/apache2/modules/mod_harbour.v2.so
    MH_LIBRARY /var/www/html/libmhapache.so
    MH_NVMS 10

除此之外，尚須新增下面設定至 httpd.conf:

    <IfModule mod_harbourV2_module>
        AddHandler harbour .prg .hrb
        AddType application/x-httpd-prg .prg .hrb
    </IfModule>

    <IfModule mime_module> 
        AddType application/x-httpd-prg .prg .hrb
    </IfModule>

否則會出現若一個完整頁面同時載入多個 .prg/.hrb 時，有些可以成功載入，有些無法成功載入情形發生!

錯誤原因不外乎某些 Message not found ...
