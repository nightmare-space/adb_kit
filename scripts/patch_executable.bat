@echo off
echo patch windows 
mkdir .\build\windows\runner\Release\data\usr\bin
xcopy .\res\windows\bin .\build\windows\runner\Release\data\usr\bin /s /f /y
xcopy .\res\windows\runtime .\build\windows\runner\Release /s /f /y

@REM debug
mkdir .\build\windows\runner\Debug\data\usr\bin
xcopy .\res\windows\bin .\build\windows\runner\Debug\data\usr\bin /s /f /y