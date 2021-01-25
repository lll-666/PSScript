#登录密码为空时限制,注册表键值LocalAccountTokenFilterPolicy  1   才能连接wmi通
#当设置为0(默认值)时，具有高完整性访问令牌的远程连接
#如果设置为1，则策略允许使用明文凭据或密码哈希，从本地管理员组的任何成员获得高完整性访问令牌的远程连接
\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System
LocalAccountTokenFilterPolicy
#https://www.cebnet.com.cn/20180209/102465550.html


#参考链接
#win7和win10已验证;   xp失败
$networkListManager = [Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]"{DCB00C01-570F-4A9B-8D69-199FDBA5723B}"))
$connections = $networkListManager.GetNetworkConnections()
#设置网络类别
#$connections | % {$_.GetNetwork().SetCategory(1)}#1-专网,0-公网
#查看网络类别
$connections | % {$_.GetNetwork().GetCategory()}

