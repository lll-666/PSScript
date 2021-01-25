#1.放开空密码限制和设置系统经典模式
$ip='10.104.180.243,10.104.180.244'
$ErrorActionPreference='Continue'
$WarningPreference='Continue'
$lsa_reg='HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'
If(!(Test-Path $lsa_reg)){$Null=md $lsa_reg -Force}
sp -Path $lsa_reg -name forceguest -Value 0
sp -Path $lsa_reg -name LimitBlankPasswordUse -Value 0
#2.防火墙规则
gsv mpssvc|%{sc.exe config mpssvc start= auto;If($_.status -ne 'Running'){sc.exe Start mpssvc}}
netsh advfirewall firewall delete rule name=ICMP_Allow_incoming_V4_echo_request
netsh advfirewall firewall add rule name=ICMP_Allow_incoming_V4_echo_request remoteip=$ip dir=in action=allow protocol=icmpv4:8,any
netsh advfirewall firewall delete rule name=WinRm_Port_Open
netsh advfirewall firewall add rule name=WinRm_Port_Open profile=any remoteip=$ip dir=in action=allow protocol=tcp localport=5985,5986
#3.设置网络为专网(家庭\私网)
Set-NetConnectionProfile -NetworkCategory Private
#([Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]"{DCB00C01-470F-4A9B-8D69-199FDBA4723B}")))|%{$_.GetNetworkConnections()|%{if ($_.getnetwork().getcategory() -eq 0) {$_.GetNetwork().SetCategory(1)}}}
([Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]"{DCB00C01-570F-4A9B-8D69-199FDBA5723B}")))|%{$_.GetNetworkConnections()|%{if ($_.getnetwork().getcategory() -eq 0) {$_.GetNetwork().SetCategory(1)}}}
([Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]"{DCB00C01-570F-4A9B-8D69-199FDBA5723B}"))).GetNetworks(1)|%{$_.SetCategory(0x01)}
([Activator]::CreateInstance([Type]::GetTypeFromCLSID('DCB00C01-570F-4A9B-8D69-199FDBA5723B'))).GetNetworks(1)|%{$_.SetCategory(0x01)}

([Activator]::CreateInstance([Type]::GetTypeFromCLSID('DCB00C01-570F-4A9B-8D69-199FDBA5723B'))).GetNetworks(1)|%{$_.GetCategory()}


netsh advfirewall firewall show rule name=WinRm_Port_Open
netsh advfirewall firewall show rule name=ICMP_Allow_incoming_V4_echo_request

cd "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles";ls|%{ sp -Path  $_.PSChildName -Name Category -Value 1}#0-公共网，1-工作网，2-域网
#生效修改的注册表项
Restart-Service mpssvc
#4.开启Powershell远程执行
#4.1开启WinRm,并设置自动启用
Enable-PSRemoting -Force
#4.2设置Powershell远程执行
Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy RemoteSigned -Force
Set-ExecutionPolicy -Scope CurrentUser  -ExecutionPolicy RemoteSigned -Force
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned -Force
#4.3设置授信主机和ps基本参数
si WSMan:\localhost\Client\TrustedHosts -Value $ip -Force
#同上，等价 WinRm s WinRm/config/client "@{TrustedHosts=$ip}"
si WSMan:\localhost\Shell\MaxConcurrentUsers 200
si WSMan:\localhost\Shell\MaxProcessesPerShell 200;
si WSMan:\localhost\Shell\MaxMemoryPerShellMB 6144;
si WSMan:\localhost\Shell\MaxShellsPerUser 200;
#4.4重启WinRm
Restart-Service WinRm

Set-ExecutionPolicy  Unrestricted -Force
$lsa_reg='HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'
If(!(Test-Path $lsa_reg)){$Null=md $lsa_reg -Force}
sp -Path $lsa_reg -name forceguest -Value 0
sp -Path $lsa_reg -name LimitBlankPasswordUse -Value 0
cd "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles";ls|%{ sp -Path  $_.PSChildName -Name Category -Value 1}
restart-service mpssvc
winrm quickconfig -q

$ErrorActionPreference='Continue';
Set-ExecutionPolicy -Scope CurrentUser Unrestricted -Force;
$lsa_reg='HKLM:\SYSTEM\CurrentControlSet\Control\Lsa';
If(!(Test-Path $lsa_reg)){$Null=md $lsa_reg -Force};
sp -Path $lsa_reg -name forceguest -Value 0;
sp -Path $lsa_reg -name LimitBlankPasswordUse -Value 0;
cd "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles";ls|%{ sp -Path  $_.PSChildName -Name Category -Value 1};
([Activator]::CreateInstance([Type]::GetTypeFromCLSID('DCB00C01-570F-4A9B-8D69-199FDBA5723B'))).GetNetworks(1)|%{$_.SetCategory(0x01)};
If([Environment]::OSVersion.version.Major -eq 6){sc.exe stop mpssvc;sc.exe start mpssvc}ElseIf($PSVersionTable.PSVersion.Major -ge 5){Set-NetConnectionProfile -NetworkCategory private}
cmd /C 'winrm quickconfig -q'


$ErrorActionPreference='Continue';
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted -Force
Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy Unrestricted -Confirm:$true
get-executionpolicy | set-executionpolicy -force
Set-ItemProperty HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell -Name ExecutionPolicy  -Value Unrestricted -Force
Set-ItemProperty HKLM:\SOFTWARE\Wow6432Node\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell -Name ExecutionPolicy  -Value Unrestricted -Force
reg add HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell /v ExecutionPolicy /t REG_SZ /d Unrestricted /f
reg add HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell /v ExecutionPolicy /t REG_SZ /d Unrestricted /f
cmd /c 'reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell" /v ExecutionPolicy /t REG_SZ /d Unrestricted /f'
cmd /c 'reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell" /v ExecutionPolicy /t REG_SZ /d Unrestricted /f'
([Activator]::CreateInstance([Type]::GetTypeFromCLSID('DCB00C01-570F-4A9B-8D69-199FDBA5723B'))).GetNetworks(1)|%{$_.SetCategory(0x01)}
cmd /c 'winrm s winrm/config/Listener?Address=*+Transport=HTTP @{Enabled="true"}'

"$ErrorActionPreference='Continue';\nSet-ExecutionPolicy -Scope CurrentUser Unrestricted -Force;\n$lsa_reg='HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Lsa';\nIf(!(Test-Path $lsa_reg)){$Null=md $lsa_reg -Force};\nsp -Path $lsa_reg -name forceguest -Value 0;\nsp -Path $lsa_reg -name LimitBlankPasswordUse -Value 0;\ncd \"HKLM:\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\NetworkList\\Profiles\";ls|%{ sp -Path  $_.PSChildName -Name Category -Value 1};\n([Activator]::CreateInstance([Type]::GetTypeFromCLSID('DCB00C01-570F-4A9B-8D69-199FDBA5723B'))).GetNetworks(1)|%{$_.SetCategory(0x01)};\nIf([Environment]::OSVersion.version.Major -eq 6){sc.exe stop mpssvc;sc.exe start mpssvc}ElseIf($PSVersionTable.PSVersion.Major -ge 5){Set-NetConnectionProfile -NetworkCategory private}\ncmd /C 'winrm quickconfig -q'"


$username='administrator'
$password='Ewq@54321'
$pass=ConvertTo-SecureString -AsPlainText $password -Force
New-Object System.Management.Automation.PSCredential -ArgumentList $Username,$pass

If(@('Restricted','Bypass','AllSigned','Restricted') -in ((Get-ExecutionPolicy -Scope CurrentUser).tostring())){Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted -Force}$ErrorActionPreference='Continue';If([Environment]::OSVersion.version.Major -eq 6){([Activator]::CreateInstance([Type]::GetTypeFromCLSID('DCB00C01-570F-4A9B-8D69-199FDBA5723B'))).GetNetworks(1)|%{$_.SetCategory(0x01)};Restart-service mpssvc;WinRm quickconfig -q}ElseIf($PSVersionTable.PSVersion.Major -ge 5){([Activator]::CreateInstance([Type]::GetTypeFromCLSID('DCB00C01-570F-4A9B-8D69-199FDBA5723B'))).GetNetworks(1)|%{$_.SetCategory(0x01)};cmd /c 'winrm set winrm/config/Listener?Address=*+Transport=HTTP @{Enabled="true"}';If(!$?){([Activator]::CreateInstance([Type]::GetTypeFromCLSID('DCB00C01-570F-4A9B-8D69-199FDBA5723B'))).GetNetworks(1)|%{$_.SetCategory(0x00)};([Activator]::CreateInstance([Type]::GetTypeFromCLSID('DCB00C01-570F-4A9B-8D69-199FDBA5723B'))).GetNetworks(1)|%{$_.SetCategory(0x01)};cmd /c 'winrm set winrm/config/Listener?Address=*+Transport=HTTP @{Enabled="true"}'}}; $error|%{$_.tostring()>>c:/test.log} 

Get-NetConnectionProfile
Get-ExecutionPolicy -list
winrm enumerate winrm/config/Listener
#还原默认设置
Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy Undefined -Force
Set-ExecutionPolicy -Scope CurrentUser  -ExecutionPolicy Undefined -Force
cmd /c 'winrm set winrm/config/Listener?Address=*+Transport=HTTP @{Enabled="false"}'
Set-NetConnectionProfile -NetworkCategory public

#查看PS远程执行策略
Get-ExecutionPolicy -list
winrm e winrm/config/Listener
get-NetConnectionProfile

#查看谁在访问你资源
Get-WmiObject -Class Win32_ServerConnection|Select-Object -Property ComputerName, ConnectionID, UserName, ShareName
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell" /v ExecutionPolicy /t REG_SZ /d Unrestricted /f