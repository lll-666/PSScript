$ip='192.168.54.108'
$userName='Administrator'
$password='Ewq@54321'

#测速本机
test-wsman
test-wsman -authentication default

#测试远程主机
Test-Wsman $ip
Test-Wsman $ip -Authentication Basic -Credential (New-Object System.Management.Automation.PSCredential($userName,(ConvertTo-SecureString $Password -asPlainText -Force)))

#使用winrm测试连通
$ho='http://'+$ip+':5985'
winrm identify -r:$ho -auth:basic -u:$userName -p:$password -encoding:utf-8

#创建远程会话
Enter-PSSession $ip -Credential (New-Object System.Management.Automation.PSCredential($userName,(ConvertTo-SecureString $Password -asPlainText -Force)))

New-PSSession

#远程执行
Invoke-Command $ip {ls c:\} -Credential (New-Object System.Management.Automation.PSCredential($userName,(ConvertTo-SecureString $Password -asPlainText -Force)))

Connect-WSMan $ip
$session=New-WSManSessionOption -operationtimeout 10000
Connect-WSMan $ip -sessionoption $session
Connect-WSMan $ip -sessionoption $session -Credential (New-Object System.Management.Automation.PSCredential($userName,(ConvertTo-SecureString $Password -asPlainText -Force)))
#指定超时时间
Connect-WSMan $ip -sessionoption $session -Credential (New-Object System.Management.Automation.PSCredential($userName,(ConvertTo-SecureString $Password -asPlainText -Force)))

Set-Item  WSMan:\localhost\Service\AllowUnencrypted -value false
Set-Item  WSMan:\localhost\Service\Auth\Basic -value false
Set-Item  WSMan:\localhost\Client\AllowUnencrypted -Value false

$ip='192.168.54.108'
$userName='Administrator'
$password='Ewq@54321'
Measure-Command{Invoke-Command $ip {} -Credential (New-Object System.Management.Automation.PSCredential($userName,(ConvertTo-SecureString $Password -asPlainText -Force)))}
Measure-Command{Test-Wsman $ip -Authentication Basic -Credential (New-Object System.Management.Automation.PSCredential($userName,(ConvertTo-SecureString $Password -asPlainText -Force)))}
$session=New-PSSession $ip -Credential (New-Object System.Management.Automation.PSCredential($userName,(ConvertTo-SecureString $Password -asPlainText -Force))) -SessionOption (New-PSSessionOption -OperationTimeout 3000)
Invoke-Command -Session $session {
	12345
	sleep 5
	54321
}


Measure-Command{Test-Wsman $ip -Authentication Basic -Credential (New-Object System.Management.Automation.PSCredential($userName,(ConvertTo-SecureString $Password -asPlainText -Force)))}
Measure-Command{Invoke-Command $ip {} -Credential (New-Object System.Management.Automation.PSCredential($userName,(ConvertTo-SecureString $Password -asPlainText -Force)))}

$dPath="C:\Program Files\Ruijie Networks\softwarePackage" 
cd $dPath

$job = Start-Job -ScriptBlock { Invoke-Command $ip {} -Credential (New-Object System.Management.Automation.PSCredential($userName,(ConvertTo-SecureString $Password -asPlainText -Force))) }
$job | Wait-Job -Timeout ( 10 ) | Remove-Job

$ip='192.168.54.124'
#$ip='192.168.54.224'
$userName='administrator'
$Password='shyfzx@163'
Measure-Command{New-PSSession $ip -Credential (New-Object System.Management.Automation.PSCredential($userName,(ConvertTo-SecureString $Password -asPlainText -Force)))}
$session=New-PSSession $ip -Credential (New-Object System.Management.Automation.PSCredential($userName,(ConvertTo-SecureString $Password -asPlainText -Force)))



Enter-PSSession 192.168.54.224 -Credential (New-Object System.Management.Automation.PSCredential('administrator',(ConvertTo-SecureString 'shyfzx@163' -asPlainText -Force)))

Measure-Command{New-PSSession 192.168.54.224 -Credential (New-Object System.Management.Automation.PSCredential('administrator',(ConvertTo-SecureString 'shyfzx@163' -asPlainText -Force)))}
Measure-Command{New-PSSession 192.168.54.214 -ThrottleLimit 5 -Credential (New-Object System.Management.Automation.PSCredential('administrator',(ConvertTo-SecureString 'shyfzx@163' -asPlainText -Force)))}

Enter-PSSession 172.17.8.179 -Credential (New-Object System.Management.Automation.PSCredential('administrator',(ConvertTo-SecureString 'sfglsyb@163' -asPlainText -Force)))

Measure-Command{ Invoke-Command -Session (New-PSSession 192.168.54.224 -Credential (New-Object System.Management.Automation.PSCredential('administrator',(ConvertTo-SecureString 'shyfzx@163' -asPlainText -Force)))) -ScriptBlock {ls c:/ }}
Measure-Command{ Invoke-Command -Session (New-PSSession 192.168.54.214 -ThrottleLimit 5 -Credential (New-Object System.Management.Automation.PSCredential('administrator',(ConvertTo-SecureString 'shyfzx@163' -asPlainText -Force)))) -ScriptBlock {ls c:/ }}

$session=Get-PSSession|? State -eq Opened|select -First 1
If(!$session){
	'#########'
	$session=New-PSSession 192.168.54.224 -Credential (New-Object System.Management.Automation.PSCredential('administrator',(ConvertTo-SecureString 'shyfzx@163' -asPlainText -Force)))
}
Invoke-Command -Session $session {Get-Service winrm}
Invoke-Command 192.168.54.224 {Get-Service winrm} -Credential (New-Object System.Management.Automation.PSCredential('administrator',(ConvertTo-SecureString 'shyfzx@163' -asPlainText -Force)))
 
 
Measure-Command{ Invoke-Command 192.168.54.214 -ScriptBlock {ls c:/ } -Credential (New-Object System.Management.Automation.PSCredential('administrator',(ConvertTo-SecureString 'shyfzx@163' -asPlainText -Force)))} 
Measure-Command{ Invoke-Command 192.168.54.214 -ScriptBlock {ls c:/ } -ThrottleLimit 5 -Credential (New-Object System.Management.Automation.PSCredential('administrator',(ConvertTo-SecureString 'shyfzx@163' -asPlainText -Force)))} 
