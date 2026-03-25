#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/utsname.h>

// CMake 会传递这些宏定义，如果未定义则提供默认值
#ifndef BUILD_TYPE
#define BUILD_TYPE "Unknown"
#endif

#ifndef TARGET_ARCH
#define TARGET_ARCH "Unknown"
#endif

// 辅助函数：执行 shell 命令并获取输出
void get_command_output(const char *cmd, char *buffer, size_t buf_size)
{
    FILE *pipe = popen(cmd, "r");
    if (!pipe)
    {
        strncpy(buffer, "Error getting info", buf_size);
        return;
    }

    if (fgets(buffer, buf_size, pipe) != NULL)
    {
        // 去除末尾换行符
        buffer[strcspn(buffer, "\n")] = 0;
    }
    else
    {
        strncpy(buffer, "N/A", buf_size);
    }
    pclose(pipe);
}

int main()
{
    printf("\n\n=== 项目构建信息 ===\n");
    printf("构建模式: %s\n", BUILD_TYPE);
    printf("架构: %s\n", TARGET_ARCH);
    printf("\n");

    printf("=== 系统环境信息 ===\n");

    // 获取内核版本
    struct utsname un;
    if (uname(&un) == 0)
    {
        printf("Linux 内核版本: %s\n", un.release);
    }
    else
    {
        printf("Linux 内核版本: 获取失败\n");
    }

    // 获取 Ubuntu 版本
    char os_info[256];
    // 尝试使用 lsb_release，这是 Ubuntu 上获取版本信息的标准方式
    get_command_output("lsb_release -ds", os_info, sizeof(os_info));
    printf("Ubuntu 版本: %s\n\n", os_info);

    return 0;
}
