@echo off
title DTSpotifyBlock Uninstaller

:: Clean up leftover temp files
if exist "%temp%\DTSpotifyBlock_Temp*" (
    for /d %%i in ("%temp%\DTSpotifyBlock_Temp*") do (
        rd /s /q "%%i"
    )
)

set flags=-uninstall
set rawUrl='https://raw.githubusercontent.com/DT-Deville/DTSpotifyBlock/refs/heads/main/install.ps1'
set setupTls=[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12;

%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe ^
-Command %setupTls% iex "& { $(iwr -useb %rawUrl%) } %flags%"

pause
exit /b
