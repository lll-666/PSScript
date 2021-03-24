#查询联网接口
netsh interface show interface
netsh interface set interface "以太网" disabled
Get-NetAdapter
#查看网卡绑定信息
Get-NetAdapterBinding
Disable-NetAdapterBinding -Name "以太网" -DisplayName "Internet 协议版本 4 (TCP/IPv4)"
#显示有线接口列表
netsh lan show interfaces
#显示所有无线设备和网络信息
netsh wlan show all

#查看联网接口绑定IP
xp
	netsh interface ip show address
xp以上
	netsh interface ipv4 show address
	
#查看终端当前活跃的IP	
(gwmi -class win32_NetworkAdapterConfiguration|?{$_.ipenabled -like $true -and $_.ServiceName -ne 'VMnetAdapter'}).ipaddress[0]

getmac.exe /FO CSV | Select -Skip 1 | ConvertFrom-Csv -Header MAC, Transport
gwmi -class win32_NetworkAdapterConfiguration|%{if($_.ipaddress -ne $null){ $_.ipaddress[0]}}
gwmi -class win32_NetworkAdapterConfiguration|?{$_.ipenabled -like $true -and $_.ServiceName -ne 'VMnetAdapter' -and $_.DefaultIPGateway}|%{if($_.ipaddress -ne $null){ $_.ipaddress[0]}}