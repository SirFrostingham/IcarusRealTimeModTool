@echo off

call .\Mods_GetLatestModScripts.cmd
call .\Mods_LaunchModGameProcess.cmd

rem Launch game
start "" "steam://run/1149460"
