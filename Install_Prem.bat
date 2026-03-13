@echo off
title DTSpotifyBlock - Premium Mode

set flags=-new_theme -premium
set rawUrl='https://raw.githubusercontent.com/DT-Deville/DTSpotifyBlock/refs/heads/main/install.ps1'
set setupTls=[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12;

%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe ^
-Command %setupTls% iex "& { $(iwr -useb %rawUrl%) } %flags%"

pause
exit /b
