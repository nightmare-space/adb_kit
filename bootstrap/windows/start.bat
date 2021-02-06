@echo off 
if "%1" == "h" goto begin 
mshta vbscript:createobject("wscript.shell").run("%~nx0 h",0)(window.close)&&exit 
:begin
cmd /c c:\Users\Nightmare\Desktop\nightmare-space\flash_tool\example\build\windows\runner\Release\example.exe