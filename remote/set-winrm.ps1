#快速配置winrm
winrm quickconfig

#查看winrm监听
winrm e winrm/config/listener

#禁用该计算机上的侦听程序，true表示启用监听（其中HTTP监听端口为5985，HTTPS监听端口为5896）
winrm set winrm/config/Listener?Address=*+Transport=HTTP @{Enabled="false"}

#将service中的allowUnencrypted设置为true，允许未加密的通讯
winrm set winrm/config/service @{AllowUnencrypted="true"}

#将client中的基本身份验证设置为true，允许
winrm set winrm/config/client/auth @{Basic="true"}
winrm set winrm/config/service/auth @{Basic="true"}

#将client中的allowUnencrypted设置为true，允许未加密的通讯
winrm set winrm/config/client @{AllowUnencrypted="true"}

#设置主机信任的客户端地址，这里host1,2,3可以填你所在的客户端机器的ip或者主机名
winrm set winrm/config/client @{TrustedHosts="host1, host2, host3"}

#启用winrm端口
winrm invoke EnableRemoting http://schemas.microsoft.com/wbem/wsman/1/config/service 
#禁用winrm端口
winrm invoke DisableRemoting http://schemas.microsoft.com/wbem/wsman/1/config/service
#禁用外壳程序（默认启用）
Set-Item WSMan:\localhost\Shell\AllowRemoteShellAccess -Value false -Force

#还原winrm默认配置
winrm invoke restore winrm/config @{}

#获取winrm的所有配置
winrm get winrm/config

#显示错误代码的描述
winrm helpmsg 0x5
winrm helpmsg 0x80338169

#设置winrm HTTP
https://docs.vmware.com/cn/vRealize-Automation/7.5/com.vmware.vrealize.orchestrator-use-plugins.doc/GUID-D4ACA4EF-D018-448A-866A-DECDDA5CC3C1.html

#设置winrm HTTPS
https://docs.vmware.com/cn/vRealize-Automation/7.5/com.vmware.vrealize.orchestrator-use-plugins.doc/GUID-2F7DA33F-E427-4B22-8946-03793C05A097.html


lggoP6zVhGXs3cWkbtEJ9vl9tqBsYyEY
Foreach($scope in @('Process','CurrentUser')){Set-ExecutionPolicy -Scope $scope 'Undefined' -Force};Set-ExecutionPolicy Unrestricted -Force


	#合规服务器配置
		#允许访问所有客户端
	cmd /c 'winrm set winrm/config/client @{TrustedHosts="*"}'	
		#启用Client的Basic模式
	cmd /c 'winrm set winrm/config/client/auth @{Basic="true"}'
		#启用Client的非加密模式
	cmd /c 'winrm set winrm/config/client @{AllowUnencrypted="true"}'
	
	#合规终端配置
		#启用Service的Basic模式
	cmd /c 'winrm set winrm/config/service/auth @{Basic="true"}'
		#启用Service的非加密模式
	cmd /c 'winrm set winrm/config/service @{AllowUnencrypted="true"}'