@echo off
:Win7网络发现依赖的服务:
:Dnscache        DNS Client
:SSDPSRV        SSDP Discovery
:PlugPlay        Plug and Play
:FDResPub        Function Discovery Resource Publication 功能发现资源发布
sc query SSDPSRV|findstr /i "SSDPSRV state"
sc query Dnscache|findstr /i "Dnscache state"
sc query PlugPlay|findstr /i "PlugPlay state"
sc query FDResPub|findstr /i "FDResPub state"
sc config SSDPSRV start= AUTO
sc config Dnscache start= AUTO
sc config PlugPlay start= AUTO
sc config FDResPub start= AUTO
sc start SSDPSRV
sc start Dnscache
sc start PlugPlay
sc start FDResPub


<#
DHCP
DNS Client、
Function Discovery Resource Publication、
SSDP Discovery、
UPnP Device Host、
Computer Browser、
Server、
TCP/IP NetBIOS Helper
#>



#关闭共享
#注册表		
	HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters
		"AutoShareServer"项,将键值由1改为0
		"AutoShareWks"项，将键值由1改为0	#禁止ADMIN$共享
	
	HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa
		restrictanonymous，将键值设为1	#禁止IPC$共享

net:#临时删除,开机之后自动恢复
	#关闭c:/windows/ 默认共享,如果直接使用命令来关闭IPC$会提示“发生系统错误 5。”“拒绝访问。” 而要关闭IPC$可以禁用“Server服务”
		net share admin$ /delete	
	#关闭各盘默认共享
		net share C$ /delete
		net share D$ /delete
		net share E$ /delete
		net share F$ /delete
		
Powershell:
	(gwmi -class win32_share).delete()
		
bat：
	@echo off
	color 2f
	echo 花月痕
	echo 删除默认共享
	net share C$ /d
	net share D$ /d
	net share ipc$ /d
	net share admin$ /d
	net share E$ /d
	net share F$ /d
	net share G$ /d
	net share H$ /d
	net share I$ /d
	net share J$ /d
	net share K$ /d
	pause
	
#参考链接:
	http://www.voidcn.com/article/p-qxjsrued-wv.html
	http://www.voidcn.com/article/p-hnxrvwcx-qw.html