@echo off
title DTSpotifyBlock Installer (Classic Theme)

:: =====================================================
:: DTSpotifyBlock - Spotify Patcher (Classic Theme)
:: =====================================================

set flags=-v 1.2.13.661.ga588f749-4064 -confirm_spoti_recomended_over -block_update_on
set rawUrl='https://raw.githubusercontent.com/DT-Deville/DTSpotifyBlock/refs/heads/main/install.ps1'
set setupTls=[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12;

%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe ^
-Command %setupTls% iex "& { $(iwr -useb %rawUrl%) } %flags%"

pause
exit /b
