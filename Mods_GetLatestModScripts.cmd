@echo off

REM set up
SET CurrentDir="%~dp0"
ECHO %CurrentDir%

REM popd first in case the script was interrupted and the directory is still set to the previous script's directory
popd
pushd %CurrentDir%

REM Get script updates
curl.exe -o ModGame.ps1 https://raw.githubusercontent.com/SirFrostingham/IcarusRealTimeModTool/main/ModGame.ps1
curl.exe -o Mods_GetLatestModScripts.cmd https://raw.githubusercontent.com/SirFrostingham/IcarusRealTimeModTool/main/Mods_GetLatestModScripts.cmd
curl.exe -o Mods_LaunchModGameProcess.cmd https://raw.githubusercontent.com/SirFrostingham/IcarusRealTimeModTool/main/Mods_LaunchModGameProcess.cmd
curl.exe -o Mods_RunIcarusWithMods.cmd https://raw.githubusercontent.com/SirFrostingham/IcarusRealTimeModTool/main/Mods_RunIcarusWithMods.cmd

REM Clean up
popd
