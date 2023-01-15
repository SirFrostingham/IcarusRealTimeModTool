@echo off
if "%~1"=="" goto skip

setlocal enableextensions
pushd %~dp0
".\UnrealPak\Engine\Binaries\Win64\UnrealPak.exe" %1 -platform="Windows" -Info > data.txt
".\UnrealPak\Engine\Binaries\Win64\UnrealPak.exe" %1 -platform="Windows" -List > data.txt
start Notepad.exe data.txt
popd


:skip