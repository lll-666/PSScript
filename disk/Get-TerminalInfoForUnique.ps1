#1.获取mac地址
getmac /FO CSV | ConvertFrom-Csv
getmac.exe /FO CSV | Select-Object -Skip 1 | ConvertFrom-Csv -Header MAC, Transport
getmac | select-string "00"
wmic nic where netconnectionid!=NULL get macaddress
wmic nic where netconnectionid!=NULL get macaddress|select -Skip 1|?{$_.trim() -ne ''}
	#获取其他主机mac地址
	nbtstat -a 192.168.54.158

#2.获取cpu序号--一个镜像安装的虚拟机是一样的
	#效率高
	wmic cpu get processorid|select -Skip 1|?{$_.trim() -ne ''}
	#效率低
	(Get-WMIObject -Class Win32_Processor).processorid

#3.获取BIOS序号
(Get-WmiObject Win32_BIOS).SerialNumber
(Get-WmiObject Win32_SystemEnclosure).SerialNumber

#4.获取硬盘序号---虚拟机不存在，会被smp+收集
wmic path win32_physicalmedia get SerialNumber
wmic path Win32_DiskDrive get SerialNumber
wmic diskdrive get SerialNumber
Get-WmiObject Win32_DiskDrive|Select SerialNumber
Get-WmiObject win32_physicalmedia | Select SerialNumber

#5.Windows的产品ID
	(get-itemproperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ProductId 已验证
	#与实际不符
	(Get-WmiObject softwareLicensingService).OA3xOriginalProductKey
	
#6.MachineGUID--重装系统发生改变--已验证过
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Cryptography MachineGUID
(Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Cryptography).MachineGUID 

#7.获取主板smBIOS UUID--（若存在双系统，则不唯一;双系统用的是同一个） 已验证过
Get-WmiObject Win32_ComputerSystemProduct|select UUID,IdentifyingNumber
wmic csproduct get UUID,IdentifyingNumber
