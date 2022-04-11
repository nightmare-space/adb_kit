@echo off
mkdir .\build\windows\runner\Release\data\usr\bin
xcopy .\res\windows .\build\windows\runner\Release\data\usr\bin /s /f
mkdir .\build\windows\runner\Debug\data\usr\bin
xcopy .\res\windows .\build\windows\runner\Debug\data\usr\bin /s /f