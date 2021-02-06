#include <stdio.h>
#include <stdlib.h>
// #pragma comment(linker, "/subsystem:windows /entry:mainCRTStartup")
int main()
{
    // printf("");
    system("del start.vbs");
    system("echo Set ws = CreateObject(\"Wscript.Shell\") >>start.vbs");
    system("echo ws.run \"cmd /c .\\scrcpy_client.exe\",0 >>start.vbs");
    system(".\\start.vbs");
    // system("del start.vbs");
    return 0;
}