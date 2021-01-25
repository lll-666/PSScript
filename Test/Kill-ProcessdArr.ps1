$Username="administrator"
$Password="Ewq@54321"
$pass=ConvertTo-SecureString -AsPlainText $password -Force
$Cred=New-Object System.Management.Automation.PSCredential -ArgumentList $Username,$pass
Invoke-Command -ComputerName 192.168.54.252 -ScriptBlock {
Function Kill-ProcessdArr([Object[]]$operator){
	$ErrorActionPreference='SilentlyContinue';
	$msg=@();
	ConvertFrom-Csv $operator|Set-ProcessdF|%{$msg+=$_}
	Return Unified-Return $msg 'Kill-ProcessdArr'
};Filter Set-ProcessdF{
	Set-Processd -processName $_.processName -isRun ('true' -eq $_.isRun) -startFile $_.startFile -isClear ('true' -eq $_.isClear)
};Function Set-Processd([String]$processName,[bool]$isRun,[String]$startFile,[bool]$isClear){
	$business="[Set-Processd $processName]=>>"
	If([String]::isNullOrEmpty($processName)){
		Return "${business}BusinessException:processName can not empty"
	}
	$pro=Get-Process $processName;
	If($isRun){
		If($pro -ne $null){
			Return "${business}No Need Operator%%SMP:success"
		}
		If([String]::isNullOrEmpty($startFile)){
			Return "${business}BusinessException:To start a process, The process startFile cannot be empty";	
		}
		
		If(!(Test-Path $startFile)){
			Return "${business}BusinessException:[$startFile] does not exist,cannot start process"
		}
		
		Start-Process $startFile;
		If(!$?){Return Print-Exception "${business}Start-Process $startFile"}
		Return Ret-Success $business
	}Else{
		If($pro -eq $null){
			If($isClear){
				If([String]::isNullOrEmpty($startFile)){
					Return "${business}BusinessException:To clean up a process, The process startFile cannot be empty";	
				}
				Remove-Item -Force $startFile;
				If(!$?){Return Print-Exception "${business}Remove-Item -Force $startFile"}
			}
			Return "${business}No Need Operator%%SMP:success"
		}
		
		$pro|Foreach{
			Stop-Process $_.Id -Force;
			If(!$?){Return Print-Exception "Stop-Process $_.Id -Force"}
		}
		Sleep 1;
		
		$pro=Get-Process $processName;	
		If($pro -ne $null){
			Return "${business}BusinessException:Failed to terminate process"
		}
		
		If($isClear){
			If([String]::isNullOrEmpty($startFile)){
				Return "${business}BusinessException:To start a process, The process startFile cannot be empty";	
			}
			
			If(!(Test-Path $startFile)){
				Return "${business}BusinessException:[$startFile] does not exist,cannot start process"
			}
			
			Remove-Item -Force $startFile;
			If(!$?){Return Print-Exception "Remove-Item -Force $startFile"}
		}
		Return Ret-Success $business
	}
};Function Ret-Success([String] $business){
	Return "$business%%SMP:success"
};Function Print-Exception([String]$command){
	Return "execute Command [$command] Exception,The Exception is $($error[0])"
};Function Unified-Return([Object[]]$msgs,[Parameter(Mandatory = $true)][String]$business){
	If($msgs -eq $Null -Or $msgs.count -eq 0){
		$isSuccess='false';
		$msg='No message returned';
	}Else{
		If(($msgs[-1]).EndsWith('%%SMP:success')){
			$isSuccess='true';
		}Else{
			$isSuccess='false';
		}
		$msg=($msgs -Join ';	').replace('\','/')
	}
	Return "{`"isSuccess`":`"$isSuccess`",`"msg`":`"$msg`",`"business`":`"$business`"}";
};<#
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
Kill-ProcessdArr @("processName","notepad++","WeChat")

} -credential $Cred
