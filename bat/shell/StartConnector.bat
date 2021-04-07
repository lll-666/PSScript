@ECHO off
CHCP 65001 > NUL & TITLE Starting Service ... & COLOR 06 & MODE CON COLS=80 LINES=20
net.exe session 1>NUL 2>NUL && GOTO EXECUTE
%1 mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd.exe","/c %~s0 ::","","runas",1)(window.close)&&exit
:EXECUTE
	CLS & ECHO ############################### starting service ############################### & ECHO.
	CD /D %~dp0
	
	SET KEY=port
	SET YML=application.yml
	For /F "tokens=*" %%i in ('findstr %KEY% %YML%') do SET PortLine=%%i
	SET port=%PortLine:port: =%
	IF %port% NEQ "" ( 
		netsh.exe advfirewall firewall show rule name=Connector_Port_%port%_Open > NUL
		IF ERRORLEVEL 0 ( netsh.exe advfirewall firewall delete rule name=Connector_Port_%port%_Open > NUL )
		netsh.exe advfirewall firewall add rule name=Connector_Port_%port%_Open profile=any dir=in action=allow protocol=tcp localport=%port% > NUL
	)
	
	SET NODE=id
	SET XML=nodeConnectorService.xml
	For /f "tokens=2 delims=>" %%i in ('findstr "<%NODE%>" %XML%') do (
		For /f "delims=<" %%i in ("%%i")do (
		   SET ser= %%i
		)
	)
	
	:delleft
		IF "%ser:~0,1%"==" " SET ser=%ser:~1%&&goto delleft
	:delright
		IF "%ser:~-1%"==" " SET ser=%ser:~0,-1%&&goto delright
	
	IF %ser%=="" ( ECHO Failed to parse configuration file %XML%, no node named ID was found & GOTO END )
	echo %ser%
	SC.exe QUERY %ser%
	IF ERRORLEVEL 1060 (GOTO NOTEXIST) ELSE (GOTO EXIST)
:NOTEXIST
	ECHO not exist %ser% service & ECHO.
	%~dp0nodeConnectorService.exe install & ECHO.
	SC.exe QUERY %ser%
	IF ERRORLEVEL 1060 (GOTO NOTEXIST_SERVICENAME) ELSE (ECHO install service of %ser% successed & ECHO.)
	SC.exe START %ser%
	TIMEOUT /T 2 > NUL
	ECHO %ser% is running & GOTO END
:NOTEXIST_SERVICENAME
	ECHO. &	ECHO please check if the service name "%ser%" is wrong in the file nodeConnectorService.xml & GOTO END
:EXIST
	ECHO exist %ser% service & ECHO.
	ECHO Stopping service %ser% & ECHO.
	SC.exe stop %ser%
	TIMEOUT /T 2 >NUL
	ECHO service %ser% stopped & ECHO.
	ECHO starting service %ser% & ECHO.
	SC.exe START %ser%
	TIMEOUT /T 2 >NUL
	ECHO %ser% is running
:END
	ECHO. & PAUSE