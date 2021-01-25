Function Set-ServicedArr([Object[]]$operator,[String]$action){
	$ErrorActionPreference='SilentlyContinue';
	$msg=@();$err=0;
	If($action -eq 'enable'){
		$startType='Automatic';
		$status='Running'
	}Else{
		$startType='Disabled';
		$status='Stopped'
	}
	
	ConvertFrom-Csv $operator|%{$null=Set-Serviced -serviceName $_.serviceName -startType $startType;Set-Serviced -serviceName $_.serviceName -status $status}|%{If(!$_.EndsWith('%%SMP:success')){$err++}$msg+=$_;}
	
	If($err -eq 0){$isSuccess='true'}Else{$isSuccess='false'}
	$t=($msg -join ' ; ').replace('\','/');
	"{`"isSuccess`":`"$isSuccess`",`"msg`":`"$t`"}"
}

<#
!!以上代码均为固定模式,非专业人士不要修改!!
!!以下代码为调度部分;调度部分用法如下
不可修改部分:
	"Set-ServicedArr"	=>调度方法
	"serviceName" 		=>服务名导航字段
	"disable"/"enable"	=>禁用/启用
可修改部分: 
	服务名,用户可根据实际业务需要进行新增或删除
功能:
	该脚本根据disable或enable做禁用和启用服务操作
格式: Set-ServicedArr @( "serviceName","服务名1",...,"服务名n" )
#>
Set-ServicedArr @('serviceName','WinRM','ftpsvc') 'disable'