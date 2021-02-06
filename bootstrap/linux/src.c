#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
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
        return 0;
    }
    else
    {
        system("nohup /home/nightmare/文档/flash_tool/example/build/linux/release/bundle/example &");
    }
}