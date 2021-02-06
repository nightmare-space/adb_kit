#include <stdlib.h>
int main()
{
    pid_t pid = fork();
    if (pid < 0)
    {
        // return throw_runtime_exception(env, "Fork failed");
    }
    else if (pid > 0)
    {
        sleep(1);
        system("kill -9 $(ps -p $PPID -o ppid=)");
        return 0;
    }
    else
    {
        system("nohup open /Users/nightmare/Desktop/nightmare-space/flash_tool/example/build/macos/Build/Products/Release/example.app &");
        // system("");
    }
    return 0;
}