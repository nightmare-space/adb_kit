@echo off
setlocal
set BASE_PATH=build\windows\x64\runner\Release
set RELEASE_PATH=%BASE_PATH%
set BIN_PATH=.\%BASE_PATH%\data\usr\bin
set RES_BIN_PATH=.\res\windows\bin
set RES_RUNTIME_PATH=.\res\windows\runtime


mkdir %BIN_PATH%
xcopy %RES_BIN_PATH% %BIN_PATH% /s /f /y
xcopy %RES_RUNTIME_PATH% %RELEASE_PATH% /s /f /y
endlocal