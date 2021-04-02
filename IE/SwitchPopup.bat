@echo off
title 弹窗阻止 - 开关 By (出处：百度知道-依梦琴瑶)
call:Kill_iexplore.exe
set "KEY=HKCU\Software\Microsoft\Internet Explorer\New Windows"
for /f "tokens=2*" %%a in ('reg query "%KEY%" /v PopupMgr') do set PDV=%%b
echo %PDV%
if "%PDV%"=="0x0" (set Value=1) else (set Value=0&set No=取消)
reg add "%KEY%" /v PopupMgr /t REG_DWORD /d %Value% /f
echo, & echo "启用弹出窗口阻止程序"已%No%勾选。
ping 127.0.0.1 -n "3">nul
pause
exit

:Kill_iexplore.exe
cls & color 0c
tasklist | find /i "iexplore.exe" >nul && (
    echo 发现您的 IE 浏览器正在运行，为了更好的进行配置，我将自动关闭所有 IE 进程，请先保存您在 IE 中的相关数据，然后在此窗口按任意键继续。
    pause>nul
    taskkill /f /im iexplore.exe
    cls
)
color 0a
goto :eof