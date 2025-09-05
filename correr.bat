@echo off
cd /d "C:\Users\Administrator\Documents\GitHub\vozy-downloads"

:: Usamos PowerShell para calcular el día de mañana en formato YYYY-MM-DD
for /f %%i in ('powershell -command "(Get-Date).AddDays(1).ToString(\"yyyy-MM-dd\")"') do set manana=%%i

:: Ejecutar Node con la fecha de mañana
node index.js %manana%

exit /b 0
