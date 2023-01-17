@echo off

@REM If Mods_GetLatestModScripts.cmd does not exist, download it
if not exist ".\Mods_GetLatestModScripts.cmd" (
    curl.exe -o Mods_GetLatestModScripts.cmd https://raw.githubusercontent.com/SirFrostingham/IcarusRealTimeModTool/main/Mods_GetLatestModScripts.cmd
)

call .\Mods_GetLatestModScripts.cmd
call .\Mods_LaunchModGameProcess.cmd

rem Launch game
start "" "steam://run/1149460"
