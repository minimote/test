@echo off
chcp 65001 >nul
cd /d "%~dp0"

for /f "delims=" %%i in ('powershell -NoProfile -Command "Get-Date -Format 'yyyy.MM.dd-HH:mm'"') do set "TS=%%i"

set "CHANGES="
for /f "delims=" %%s in ('git status --porcelain -uall') do (
    if not defined CHANGES (
        echo.
        echo 即将「提交」以下更改：
    )
    set "CHANGES=1"
    echo   %%s
)
if not defined CHANGES (
    echo.
    echo 无「提交」内容，仅推送
)

echo.
echo 即将「强制」推送到以下远端：
for /f "delims=" %%r in ('git remote') do (
    for /f "delims=" %%u in ('git remote get-url --push --all %%r') do echo   - %%r: %%u
)

echo.
set "CONFIRM="
set /p "CONFIRM=按回车键「确认」全部执行，输入其他任意字符取消： "
if defined CONFIRM (
    echo [取消] 已中止，未做任何改动
    pause
    exit /b 0
)

git add -A
if errorlevel 1 (
    echo [错误] git add 失败
    pause
    exit /b 1
)

git diff --cached --quiet
if errorlevel 1 (
    git commit -m "%TS%"
    if errorlevel 1 (
        echo [错误] 提交失败
        pause
        exit /b 1
    )
) else (
    echo [跳过] 没有需要提交的更改
)

git push --force --all
if errorlevel 1 (
    echo [错误] 推送分支失败
    pause
    exit /b 1
)

git push --force --tags
if errorlevel 1 (
    echo [错误] 推送标签失败
    pause
    exit /b 1
)

echo [完成]
pause
