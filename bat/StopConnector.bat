@ECHO off
CHCP 65001 > NUL & TITLE Starting Service ... & COLOR 06 & MODE CON COLS=80 LINES=20
net.exe session 1>NUL 2>NUL && GOTO EXECUTE
%1 mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd.exe","/c %~s0 ::","","runas",1)(window.close)&&exit
:EXECUTE
	CLS & ECHO ############################### stopping service ############################### & ECHO.
	cd /D %~dp0
	
	SET KEY=port
	SET YML=application.yml
	For /F "tokens=*" %%i in ('findstr %KEY% %YML%') do SET PortLine=%%i
	SET port=%PortLine:port: =%
	IF %port% NEQ "" ( netsh advfirewall firewall delete rule name=Connector_Port_%port%_Open > NUL )

	SET NODE=id
	SET XML=nodeConnectorService.xml
	For /f "tokens=2 delims=>" %%i in ('findstr "<%NODE%>" %XML%') do (
		For /f "delims=<" %%i in ("%%i")do (
		   SET ser= %%i
		)
	)
	
	:delleft
		IF "%ser:~0,1%"==" " set ser=%ser:~1%&&goto delleft
	:delright
		IF "%ser:~-1%"==" " set ser=%ser:~0,-1%&&goto delright
		
	IF %ser%=="" ( ECHO Failed to parse configuration file %XML%, no node named ID was found & GOTO END )
	SC QUERY %ser% > NUL
	IF ERRORLEVEL 1060 (GOTO NOTEXIST) ELSE (GOTO EXIST)
:NOTEXIST
	ECHO not exist %ser% service & ECHO. & GOTO END
:EXIST
	ECHO exist %ser% service & ECHO. & SC stop %ser% 
	TIMEOUT /T 2 > NUL
	%~dp0nodeConnectorService.exe uninstall & GOTO END
:END
	ECHO stop service %ser% successfully & ECHO.
PAUSE