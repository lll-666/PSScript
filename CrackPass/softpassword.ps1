echo "本脚本需要3个文件，位于d:/pwd下"
echo "1 name.csv,保存需要测试的用户名列表 "
echo "2 pwd.csv，保存需要测试的密码列表"
echo "3 name2.csv，保存验证成功的密码"
echo "域不能限制测试密码次数，必须管理员方式运行"
$files=(Get-Childitem d:\pwd\name2.csv).pspath
$content=get-content $files
Import-Csv -Path D:\pwd\name.csv|foreach { 
	$bb="{0}" -F $_.name
	$UserName="tech\" + "$bb"
	Import-Csv -Path D:\pwd\pwd.csv|foreach {
		$pwd2="{0}" -F $_.pwd
		$pass=ConvertTo-SecureString -AsPlainText $_.pwd -Force
		$cred=New-Object System.Management.Automation.PSCredential($UserName,$Pass) 
		$dCred=$cred
		$dUsername=$dCred.username
		$dPassword=$dCred.GetNetworkCredential().password
		$currentDomain="LDAP://" + ([ADSI]"").distinguishedName
		$auth=New-Object System.DirectoryServices.DirectoryEntry($CurrentDomain,$dUserName,$dPassword)
		if($auth.name -eq $null){
			Write-Host 当前测试用户$bb 当前测试密码$pwd2
			Write-Host "验证密码失败." -foregroundcolor 'Red'
		}else{
			Write-Host 当前测试用户$bb 当前测试密码$pwd2
			Write-Host "密码测试成功 -> " $($auth.Name) -foregroundcolor 'green'
			$a="密码测试成功 -> $UserName $pwd2" |Out-File -Append  D:\pwd\name2.csv    
		}
	}
}



Import-Module ActiveDirectory
$ou = "OU=allusers,DC=starwing,DC=local"
$pwd = "1qaz@WSX","123456"
$users = Get-ADUser -Filter {Enabled -eq $true} -SearchBase $ou
foreach($user in $users){
	$sam=$user.sAMAccountName
	foreach($password in $pwd){               
		$Auth=New-Object System.DirectoryServices.DirectoryEntry("LDAP://$($ou)","$sam", "$password")               
		If($Auth.name){                   
			Write-Host "[Warning] $($sam)'s Password is Unsecured [$password]" -ForegroundColor Yellow -BackgroundColor Black               
		}           
	}
}