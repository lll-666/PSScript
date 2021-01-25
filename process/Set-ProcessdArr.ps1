Function Set-ProcessdArr([Object[]]$operator){
	$ErrorActionPreference='SilentlyContinue';
	$msg=@();
	ConvertFrom-Csv $operator|Set-ProcessdF|%{$msg+=$_}
	If($error.count -eq 0){$isSuccess='true'}Else{$isSuccess='false';#$msg+=$error
	}
	$t=($msg -join ' ; ').replace('\','/');
	"{`"isSuccess`":`"$isSuccess`",`"msg`":`"$t`"}"
}
<#
!!以上代码均为固定模式,非专业人士不要修改!!
!!以下代码为调度部分;调度部分用法如下
不可修改部分:
	"Set-ProcessdArr"	=>调度方法
	"processName" 		=>进程名 导航字段
可修改部分: 
	进程名,用户可根据实际业务需要进行新增或删除
功能:
	杀死指定进程操作
格式: Set-ProcessdArr @( "processName","进程名1",...,"进程名n" )
#>
Set-ProcessdArr @("processName","notepad++","WeChat")