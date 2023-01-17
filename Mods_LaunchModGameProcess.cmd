@echo off

REM set up
SET CurrentDir="%~dp0"
ECHO %CurrentDir%

REM popd first in case the script was interrupted and the directory is still set to the previous script's directory
popd
pushd %CurrentDir%

REM Set up the environment
powershell Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

REM Run the mod game script
powershell .\ModGame.ps1

REM Customize LOCAL Client side stuff here
IF EXIST ".\Mods_CustomLocalOperations.cmd" (
	REM You must make this file and put stuff in it
	call .\Mods_CustomLocalOperations.cmd
)

REM Clean up
popd
