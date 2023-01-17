@echo on

REM set up
SET CurrentDir="%~dp0"
ECHO %CurrentDir%

REM popd first in case the script was interrupted and the directory is still set to the previous script's directory
popd
pushd %CurrentDir%

REM Get script updates
curl.exe -o ModGame.ps1 https://raw.githubusercontent.com/SirFrostingham/IcarusRealTimeModTool/main/ModGame.ps1
curl.exe -o LAUNCHICARUS.cmd https://raw.githubusercontent.com/SirFrostingham/IcarusRealTimeModTool/main/LaunchIcarusWithMods.cmd

REM powershell Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
powershell Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
powershell .\ModGame.ps1

REM Customize LOCAL Client side stuff here
IF EXIST ".\CustomLocalOperations.cmd" (
	REM You must make this file and put stuff in it
	call .\CustomLocalOperations.cmd
)

REM Clean up
popd

rem Launch game
start "" "steam://run/1149460"
