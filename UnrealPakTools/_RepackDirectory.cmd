@if "%~1"=="" goto skip

@setlocal enableextensions
@if exist %~dp0autogen.txt (del /q %~dp0data\autogen.txt)
@pushd %~dp0\data
@echo off & for /f "delims=*" %%A in ('dir /s /b /a:-d ') do echo %%~fA >> %~dp0data\autogen.txt
"%~dp0UnrealPak\Engine\Binaries\Win64\UnrealPak.exe" "%~dp0\%~1_P.pak" -platform="Windows" -create="%CD%\autogen.txt"
@popd
@REM @pause

:skip