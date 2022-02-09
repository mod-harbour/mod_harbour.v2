# mod_harbour.v2.1
mod_harbour.v2.1 - Harbour Apache Module 

Add these lines at the bottom of httpd.conf

```
WINDOWS
LoadModule mod_harbourV2_module modules/mod_harbour.v2.so
MH_LIBRARY c:\\xampp\htdocs\\libmhapache.dll
MH_NVMS 10

LINUX( Not tested yet!!! )
LoadModule mod_harbourV2_module /usr/lib/apache2/modules/mod_harbour.v2.so
MH_LIBRARY /var/www/html/libmhapache.so
MH_NVMS 10

<FilesMatch "\.(prg|hrb)$">
    SetHandler harbour
</FilesMatch>

```
