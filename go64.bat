@echo off
cls

@del output\win64\mod_harbour.v2.* /Q
@del output\win64\libmhapache.* /Q

call "%ProgramFiles(x86)%\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat" x86_amd64

c:\harbour\bin\win\msvc64\hbmk2 mod_harbour.v2.1.hbp -comp=msvc64 

if errorlevel 1 goto error

@del output\win64\mod_harbour.v2.exp
@del output\win64\mod_harbour.v2.lib
@del output\win64\libmhapache.exp
@del output\win64\libmhapache.lib

goto exit

:error
@echo *** Error compile ***

:exit

pause
