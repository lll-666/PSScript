Function Black-Regist([Object[]] $operator){
	$WarningPreference='SilentlyContinue';
	$ErrorActionPreference='SilentlyContinue';
	$msg=@();$err=0;
	ConvertFrom-Csv $operator|Remove-RegistKey|%{If(!$_.EndsWith('%%SMP:success')){$err++}$msg+=$_}
	If($err -eq 0){$isSuccess='true'}Else{$isSuccess='false'}
	$t=($msg -join ' ; ').replace('\','/');
	"{`"isSuccess`":`"$isSuccess`",`"msg`":`"$t`"}"
}
Filter Remove-RegistKey{
	$business='Remove-RegistKey [item='+$_.item+',key='+$_.key+"] "
	If([String]::IsNullOrEmpty($_.item) -Or [String]::IsNullOrEmpty($_.key)){
		Return "${business}Required field cannot be empty"
	}
	If(!(Test-Path $_.item)){
		Return "${business}:item of registry does not exist%%SMP:success"
	}Else{
		$Null=Get-ItemProperty $_.item $_.key -ErrorAction SilentlyContinue;
		If(!$?){
			Return "${business}:key of registry does not exist%%SMP:success"
		}Else{
			Remove-ItemProperty $_.item $_.key -Force -ErrorAction SilentlyContinue;
			If(!$?){
				Return "${business}Exception,The Exception is [$($error[0])]";
			}
			Return "${business}%%SMP:success"
		}
	}
}
<#
!!以上代码均为固定模式,非专业人士不要修改!!
不可修改部分:
	'White-Regist'为调度方法
	"item,key"分别代表 注册表项 及 项下的键,不要修改
可修改部分(用户可根据业务进行修改): 
	"项1,键1"
格式: Black-Regist @( "item,key","项1,键1",...,"项n,键n" )
#>
Black-Regist @("item,key","HKLM:\Software\Test,Password1","HKLM:\Software\Test,Password5")