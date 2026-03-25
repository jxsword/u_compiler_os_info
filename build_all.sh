#!/bin/bash

set -e # 遇到错误立即停止

echo "🚀 开始全量构建 (4种组合)..."

BUILD_TYPES=("Debug" "Release")
ARCHS=("x64" "x86")

check_multilib() {
    echo "🔍 检查 32 位编译环境 (含链接测试)..."

    # 创建临时文件
    TEMP_FILE=$(mktemp --suffix=.c)
    TEMP_BIN=$(mktemp) # 需要一个临时二进制文件用于链接测试

    # 清理函数
    cleanup() {
        rm -f "$TEMP_FILE" "$TEMP_BIN"
    }
    trap cleanup RETURN # 函数返回时自动清理

    echo "int main(){return 0;}" > "$TEMP_FILE"

    # 🔥 关键修改：去掉 -c，进行完整编译 + 链接
    # 如果缺少 multilib，这里会报 "cannot find -lc" 或类似链接错误
    if gcc -m32 "$TEMP_FILE" -o "$TEMP_BIN" 2>/dev/null; then
        # echo "✅ 32 位环境完整可用 (编译 + 链接 均成功)"
        return 0
    else
        # echo "缺少 32 位环境，请手动安装 multilib!"
        # return 1
        echo "⚠️ 32 位环境缺失 (链接失败)，正在自动安装 gcc-multilib..."

        # 执行安装
        sudo dpkg --add-architecture i386 || true
        sudo apt-get update
        sudo apt-get install -y gcc-multilib g++-multilib

        # 再次验证
        if gcc -m32 "$TEMP_FILE" -o "$TEMP_BIN" 2>/dev/null; then
             echo "✅ 安装成功，环境已就绪"
             return 0
        else
             echo "❌ 严重错误：安装 multilib 后仍然无法链接 32 位程序!"
             echo "   请检查系统日志或手动运行 'gcc -m32 test.c' 排查"
             return 1
        fi
    fi
}

APPNAME=app

rm -rf build && mkdir build

for TYPE in "${BUILD_TYPES[@]}"; do
    for ARCH in "${ARCHS[@]}"; do
        DIR_NAME="build/${TYPE,,}-${ARCH}"
        echo "🔨 正在构建: $TYPE + $ARCH (目标: $APPNAME)"

        mkdir -p "$DIR_NAME"
        cd "$DIR_NAME"

        CMAKE_ARGS="-DCMAKE_BUILD_TYPE=$TYPE"

        # 🔥 动态传入项目名称变量
        # 这样即使以后 CMakeLists.txt 被复用到其他项目，脚本也能控制生成的名字
        CMAKE_ARGS="$CMAKE_ARGS -DPROJECT_NAME=$APPNAME"

        if [ "$ARCH" == "x86" ]; then
            check_multilib
            CMAKE_ARGS="$CMAKE_ARGS -DCMAKE_C_FLAGS=-m32"
        else
            # 显式指定 -m64 用于测试，实际环境默认安装的就是 64 位工具链，-m64 可以省略
            CMAKE_ARGS="$CMAKE_ARGS -DCMAKE_C_FLAGS=-m64"
        fi

        cmake ../../ $CMAKE_ARGS
        cmake --build . -j$(nproc)

        # 🔥 运行生成的二进制文件 (使用变量名，而不是固定的 'app')
        ./$APPNAME

        cd ../..
    done
done

echo ""
echo "所有组合构建完成!"
echo "生成的二进制文件信息:"
find build -name "$APPNAME" -type f -exec file {} \;
# echo "生成的目标文件运行结果"

