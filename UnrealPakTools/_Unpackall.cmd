@REM For each .pak file in the current directory, unpack it to a subdirectory
@REM with the same name as the .pak file.

@REM RECURSIVE
@REM for /r %%i in (.\*.pak) do _unpack.cmd %%i

REM set up
SET CurrentDir="%~dp0"
ECHO %CurrentDir%

REM popd first in case the script was interrupted and the directory is still set to the previous script's directory
popd
pushd %CurrentDir%

for %%i in (*.pak) do _Unpack.cmd %%i


REM Clean up
popd
