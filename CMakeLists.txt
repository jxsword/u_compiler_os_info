cmake_minimum_required(VERSION 3.10)

# -----------------------------------------------------------
# 1. 项目定义与目标名称变量化
# -----------------------------------------------------------
# 如果外部未传入 PROJECT_NAME，则使用默认值 "SystemInfoApp"
# 用法: cmake -DPROJECT_NAME=MyCustomApp ..
if(NOT DEFINED PROJECT_NAME)
    set(PROJECT_NAME "SystemInfoApp")
endif()

project(${PROJECT_NAME} C)

# 将目标名称存入变量，方便后续统一引用
set(TARGET_NAME ${PROJECT_NAME})

message(STATUS "========================================")
message(STATUS "🚀 项目配置: ${TARGET_NAME}")
message(STATUS "========================================")

# -----------------------------------------------------------
# 2. 基础设置
# -----------------------------------------------------------
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)

# 如果未指定构建类型，默认为 Release
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()
message(STATUS "Build Type: ${CMAKE_BUILD_TYPE}")

# -----------------------------------------------------------
# 3. 架构检测 (32-bit vs 64-bit)
# -----------------------------------------------------------
# CMAKE_SIZEOF_VOID_P 会自动根据编译器标志 (如 -m32) 变化
if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(ARCH_STRING "64-bit")
    set(ARCH_MACRO_VALUE 64)
elseif(CMAKE_SIZEOF_VOID_P EQUAL 4)
    set(ARCH_STRING "32-bit")
    set(ARCH_MACRO_VALUE 32)
else()
    set(ARCH_STRING "Unknown-Arch")
    set(ARCH_MACRO_VALUE 0)
endif()
message(STATUS "Target Architecture: ${ARCH_STRING} (Ptr Size: ${CMAKE_SIZEOF_VOID_P})")

# -----------------------------------------------------------
# 4. 针对不同构建模式的编译选项
# -----------------------------------------------------------

# --- Debug 模式 ---
# 保留默认标志 (如 -g)，追加自定义标志
set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -O0 -Wall -Wextra -DDEBUG_VERBOSE=1")
message(STATUS "Debug Flags: ${CMAKE_C_FLAGS_DEBUG}")

# --- Release 模式 ---
# 保留默认标志 (如 -O3)，追加自定义标志
set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -O3 -Wall -DNDEBUG -DRELEASE_OPTIMIZED=1")
message(STATUS "Release Flags: ${CMAKE_C_FLAGS_RELEASE}")

# -----------------------------------------------------------
# 5. 创建可执行文件 (使用变量)
# -----------------------------------------------------------
# 假设源文件名为 main.c，如果源文件也变化，可以同样设为变量
set(SOURCE_FILES src/main.c)

add_executable(${TARGET_NAME} ${SOURCE_FILES})

# -----------------------------------------------------------
# 6. 定义传递给代码的宏
# -----------------------------------------------------------
target_compile_definitions(${TARGET_NAME} PRIVATE
    # 字符串宏
    BUILD_TYPE="${CMAKE_BUILD_TYPE}"
    TARGET_ARCH="${ARCH_STRING}"
    PROJECT_NAME_STR="${TARGET_NAME}"

    # 数字宏 (方便逻辑判断)
    ARCH_BIT=${ARCH_MACRO_VALUE}

    # 条件编译辅助宏 (生成器表达式)
    $<$<CONFIG:Debug>:IS_DEBUG_BUILD>
    $<$<CONFIG:Release>:IS_RELEASE_BUILD>
)

message(STATUS "✅ 配置完成: 目标 '${TARGET_NAME}' 已就绪")
message(STATUS "========================================")
