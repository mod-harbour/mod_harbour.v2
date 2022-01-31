# mod_harbour.v2
mod_harbour.v2 - Harbour Apache standalone Module 

Add these lines at the bottom of httpd.conf

```
WINDOWS
LoadModule harbourV2_module modules/mod_harbour.v2.so

LINUX( Ubuntu64 )
LoadModule harbourV2_module /usr/lib/apache2/modules/mod_harbour.v2.so

<FilesMatch "\.(prg|hrb)$">
    SetHandler harbour
</FilesMatch>

```
