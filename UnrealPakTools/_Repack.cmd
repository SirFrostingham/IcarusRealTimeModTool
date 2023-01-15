@REM @if "%~1"=="" goto skip

@REM @setlocal enableextensions
@REM @pushd %~dp0
@REM @echo "%~1\*.*" "..\..\..\Icarus\Content\*.*" > autogen.txt
@REM ".\UnrealPak\Engine\Binaries\Win64\UnrealPak.exe" "%~1 _P.pak" -platform="Windows" -create="%CD%\autogen.txt"
@REM @popd
@REM @REM @pause

@REM :skip

@if "%~1"=="" goto skip

@setlocal enableextensions
@pushd %~dp0
@echo "%~1\*.*" "..\Icarus\Content\*.*" > autogen.txt
".\UnrealPak\Engine\Binaries\Win64\UnrealPak.exe" "%~1_P.pak" -platform="Windows" -create="%CD%\autogen.txt"
@popd
@REM @pause

:skip