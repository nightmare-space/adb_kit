@echo off
@REM flutter clean
echo a
flutter build windows
echo b
xcopy .\res\windows\runtime .\build\windows\runner\Release /s /f
Compress-Archive -Path .\build\windows\runner\Release\* -DestinationPath "windows.zip"