Function Set-PasswordExpiresForIp([String] $ip,[String]$verifiedAccount,[String]$pass,[String] $modifyAccount,[ValidateSet('false','true')]$expire){
	$session=New-PSSession $ip -Authentication Default -Credential (Get-PSCredential $verifiedAccount $pass) -ErrorAction SilentlyContinue
	If(!$? -or ($session -eq $null)){Return WriteLog "false" "New-PSSession $ip -Authentication Default -Credential (Get-PSCredential $acc $pass)" "the exception is $($error[0])"}
	
	$ret=Invoke-Command -Session $session{
		Function Set-PasswordExpires([String]$acc, [ValidateSet('false','true')]$expire){
			Function Set-PE($acc,$expire){
				cmd /c "wmic.exe UserAccount Where Name=`"$acc`" Set PasswordExpires=`"$expire`""
				If(!$?){Return "false","The Exception is $error(0)"}
				$ret=cmd /c "wmic.exe UserAccount Where Name=`"$acc`" Get PasswordExpires"
				If($ret|?{$_ -like "*$expire*"}){Return "true","Property modified successfully"}
				Return "false",$ret
			}
			
			$ret=cmd /c "wmic.exe UserAccount Where Name=`"$acc`" Get PasswordExpires"
			If(!$? -or ($ret -eq $null)){Return "false","The Exception is $error(0)"}
			Foreach($r in $ret){
				If('false' -eq $r.trim()){
					If('false' -eq $expire){Return "true","no need handle"}
					Return Set-PE($acc,$expire)
				}ElseIf('true' -eq $r.trim()){
					If('true' -eq $expire){Return "true","no need handle"}
					Return Set-PE($acc,$expire)
				}
			}
			Return "false","No Instance(s) Available"
		}
		Set-PasswordExpires $args[0] $args[1]
	} -ArgumentList $modifyAccount,$expire -ErrorAction SilentlyContinue
	
	If($?){
		WriteLog $ret[0] 'Invoke-Command' $ret[1]
	}Else{
		WriteLog 'false' 'Invoke-Command' "the exception is $($error[0])"
	}
}

Function Get-PSCredential($acc,$pass){New-Object System.Management.Automation.PSCredential $acc, (ConvertTo-SecureString $pass -AsPlainText -Force)}
Function WriteLog($isSuccess,$command,$msg){
	New-Object PSObject -Property @{
			ip=$ip;
			isSuccess=$isSuccess;
			command=$command;
			msg=($msg -join ';');
			date="$((Get-Date).tostring())"
	}|select date,ip,isSuccess,command,msg|Export-Csv "${tmp}_acc.csv" -Encoding UTF8 -Append
}
	
Function Set-PasswordExpiresForIpList([String[]] $ipList,[String]$verifiedAccount,[String[]]$passes,[String] $modifyAccount,[ValidateSet('false','true')]$expire){
	$error.Clear()
	
	$logDir="$env:USERPROFILE\desktop\logDir\"
	If(!(Test-Path $logDir)){$null=mkdir $logDir}
	$tmp="$logDir$(Get-Date -Format 'yyyyMMddHHmmss')"

	arp -a | Out-File "${tmp}_arp_start.txt" -Encoding UTF8 -Append
	Foreach($ip in $ipList){
		$null=Test-Wsman $ip -ErrorAction SilentlyContinue
		If(!$?){Return WriteLog "false" "Test-Wsman $ip" "the exception is $($error[0])"}
		Foreach($pass in $passes){Set-PasswordExpiresForIp $ip $verifiedAccount $pass $modifyAccount $expire}
	}
	arp -a | Out-File "${tmp}_arp_end.txt" -Encoding UTF8 -Append
}

Set-PasswordExpiresForIpList -ipList @('192.168.54.187','192.168.54.150','192.168.17.2') -verifiedAccount 'hp' -passes @('jjjjj','shenmegui123') -modifyAccount 'Nodemanager' -expire 'false'
<#
参数解读部分
ipList-主机列表，verifiedAccount-认证账号，passes-认证账号可尝试的密码列表，modifyAccount-将要被改变的账号，expire-账号密码失效配置（true-会失效，false-永不失效）
脚本执行结果会输出到当前用户桌面上的logDir目录下。
#>