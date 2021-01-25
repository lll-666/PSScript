mac地址修改
	http://www.360doc.com/content/11/0308/22/2461351_99370808.shtml
	windows界面:	https://www.yunqishi.net/video/10083.html
	注册表方式:		计算机\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}
	
防修改
	gpedit.msc：组策略》用户配置》管理模板》网络》网络连接》禁止访问LAN连接组件属性
	
	
win7和win10下
	默认情况下
		普通用户，网络连接属性是点亮的，但若要修改则输入管理员密码即可
	在管理员模式下，修改组策略（禁用访问网络连接属性）
		普通用户，网络连接属性是灰色的，无操作事件