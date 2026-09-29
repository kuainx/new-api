@echo off
chcp 65001 >nul
setlocal

set "BASE_VERSION=1.0.0"
set "SUFFIX="

echo ============================================
echo            new-api 编译脚本
echo ============================================
echo.

REM 支持命令行参数直接传版本号，例如: build.bat rc37
if not "%~1"=="" (
    set "SUFFIX=%~1"
    goto :got_version
)

:input_version
set "SUFFIX="
set /p "SUFFIX=请输入版本号后缀 (例如 rc37): "
if not defined SUFFIX (
    echo [错误] 版本号不能为空，请重新输入。
    echo.
    goto :input_version
)

:got_version
set "TARGET=new-api-v%BASE_VERSION%-%SUFFIX%.exe"

echo.
echo [信息] 输出文件名: %TARGET%
echo.

REM ---------- 环境检查 ----------
where go >nul 2>nul
if errorlevel 1 (
    echo [错误] 未找到 go 命令，请先安装 Go 并加入 PATH。
    pause
    exit /b 1
)
where bun >nul 2>nul
if errorlevel 1 (
    echo [错误] 未找到 bun 命令，请先安装 Bun 并加入 PATH。
    pause
    exit /b 1
)
if not exist "web" (
    echo [错误] 当前目录下未找到 web 文件夹，请把本脚本放在 new-api 项目根目录执行。
    pause
    exit /b 1
)

REM ---------- 1. 编译前端 ----------
echo.
echo [1/2] 正在编译前端 (web)...
pushd web
call bun run build
if errorlevel 1 (
    echo.
    echo [错误] 前端编译失败！
    popd
    pause
    exit /b 1
)
popd

REM ---------- 2. 编译后端 ----------
echo.
echo [2/2] 正在编译后端 (go build)...
go build -o "%TARGET%"
if errorlevel 1 (
    echo.
    echo [错误] 后端编译失败！
    pause
    exit /b 1
)

echo.
echo ============================================
echo   编译成功: %TARGET%
echo ============================================
pause
endlocal