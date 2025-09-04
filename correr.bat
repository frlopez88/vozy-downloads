@echo off
cd /d "C:\Users\Administrator\Documents\GitHub\vozy-downloads"
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (
    set dia=%%a
    set mes=%%b
    set anio=%%c
)

set hoy=%anio%-%mes%-%dia%

node index.js %hoy%

exit /b 0