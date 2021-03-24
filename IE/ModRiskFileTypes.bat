@ECHO off
CHCP 65001 > NUL & TITLE Starting Service ... & COLOR 06 & MODE CON COLS=80 LINES=20
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
	echo Requesting administrative privileges...
	goto UACPrompt
) else ( goto gotAdmin )
:UACPrompt
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
"%temp%\getadmin.vbs"
exit /B
:gotAdmin
if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
pushd "%CD%"
CD /D "%~dp0"
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Associations /v ModRiskFileTypes /t REG_SZ /d .exe;.bat;.vbs /f
gpupdate /force
pause