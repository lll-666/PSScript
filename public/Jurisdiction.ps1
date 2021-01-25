#win10权限问题
#放权
Set-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name EnableLUA  -Value 0
#收权
Set-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name EnableLUA  -Value 1

#UAC:用户账户控制
通知用户是否对应用程序使用硬盘驱动器和系统文件授权


Function AA(){

	Foreach($i in 1..3){
		$i
		If($i -eq 2){Break}
	}
	11111

}




HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers
	#在下面增加一个字符串值，名称是exe的路径，类型就是REG_SZ,数据是:RUNASADMIN