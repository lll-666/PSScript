Invoke-Command -ComputerName 192.168.54.252 -ScriptBlock {
Function Enable-ServicedArr([Object[]]$operator){
	Set-ServicedArr $operator 'enable'
};Function Set-ServicedArr([Object[]]$operator,[String]$action){
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
};Filter Set-ServicedF{
	Return Set-Serviced $_.serviceName $_.startType $_.status
};Function Set-Serviced([String]$serviceName,[String]$startType,[String]$status){
	$business="[Set-Serviced $serviceName]=>>"
	If([String]::IsNullOrEmpty($serviceName)){Return "$business The serviceName can not empty"}
	$service=Get-Service $serviceName -ErrorAction SilentlyContinue;
	If(!$?){
		If($error[0].ToString().Contains('Cannot find any service')){
			If('Stopped' -eq $status){Return "Cannot find any service with service name ${serviceName} %%SMP:success"}
		}
		Return Print-Exception "${business}Get-Service $serviceName"
	}
	If(![String]::IsNullOrEmpty($status) -And $service.status -ne $status){
		If('Running' -eq $service.status){
			Stop-Service $serviceName -Force -ErrorAction SilentlyContinue;
			If(!$?){Return Print-Exception "Stop-Service $serviceName -Force"}
		}Else{
			Start-Service $serviceName -ErrorAction SilentlyContinue;
			If(!$?){Return Print-Exception "Start-Service $serviceName"}
		}
	}
	#StartupType:[Boot|System|Automatic|Manual|Disabled],Status:[Running|Stopped|Paused]
	if(![String]::IsNullOrEmpty($startType) -And $service.StartType -ne $startType){
		Set-Service $serviceName -StartupType $startType -ErrorAction SilentlyContinue;
		If(!$?){Return Print-Exception "${business}Set-Service $serviceName -StartupType $startType"}
	}	
	Return Ret-Success $business
};Function Ret-Success([String] $business){
	Return "$business%%SMP:success"
};Function Print-Exception([String]$command){
	Return "execute Command [$command] Exception,The Exception is $($error[0])"
};<#
!!以上代码均为固定模式,非专业人士不要修改!!
!!以下代码为调度部分;调度部分用法如下
不可修改部分:
	"Enable-ServicedArr"	=>调度方法
	"serviceName" 		=>服务名导航字段
可修改部分: 
	服务名,用户可根据实际业务需要进行新增或删除
功能:
	启用指定服务操作
格式: Enable-ServicedArr @( "serviceName","服务名1",...,"服务名n" )
#>
Enable-ServicedArr @('serviceName','WinRM','ftpsvc')


} -credential $Cred
