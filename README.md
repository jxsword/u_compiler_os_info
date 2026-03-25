在 ubuntu 环境用 cmake 构建C语言项目。使用用 github action ci。

项目构建模式：debug、release
CPU架构：x86、x64

main.c 实现：

- 输出当前项目构建模式：debug or release，x86 or x64
- 输出 Linux 内核版本、ubuntu 版本信息

## 本地构建测试

```
./build_all.sh
# 或
bash build_all.sh
```
