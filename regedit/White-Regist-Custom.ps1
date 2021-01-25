Function White-Regist([Object[]] $operator){
	$WarningPreference='SilentlyContinue';
	$ErrorActionPreference='SilentlyContinue';
	$msg=@();$err=0;
	ConvertFrom-Csv $operator|Add-Regist|%{If(!$_.EndsWith('%%SMP:success')){$err++}$msg+=$_;}
	If($err -eq 0){$isSuccess='true'}Else{$isSuccess='false'}
	$t=($msg -join ' ; ').replace('\','/');
	"{`"isSuccess`":`"$isSuccess`",`"msg`":`"$t`"}"
}
Filter Add-Regist{
	$business='Add-Regist [item='+$_.item+',key='+$_.key+$_.val+','+$_.type+"] "
	If([String]::IsNullOrEmpty($_.item) -Or [String]::IsNullOrEmpty($_.key)){
		Return "${business}Required field cannot be empty"
	}
	If(!(Test-Path $_.item)){
		$Null=md $_.item -Force;
		If(!$?){Return "${business}Exception,The Exception is [$(($error[0]).ToString().Trim())]"}
	}	
	If($_.type -eq 'Binary'){
		[Byte[]][Char[]]$tmp=$_.val
	}Else{
		$tmp=$_.val
	}
	Set-ItemProperty $_.item $_.key $tmp -type $_.type -Force;
	If(!$?){Return "${business}Exception,The Exception is [$(($error[0]).ToString().Trim())]"}
	Return "${business}%%SMP:success"
}
<#
!!以上代码均为固定模式,非专业人士不要修改!!
不可修改部分:
	'White-Regist'为调度方法
	"item,key,val,type"分别代表 注册表项 及 项下的键,不要修改
可修改部分(用户可根据业务进行修改): 
	"项,键,值,值类型"
格式: White-Regist @( "item,key,val,type","项1,键1,值1,值类型1",...,"项n,键n,值n,值类型n" )
#>
White-Regist @("item,key,val,type","HKLM:\Test,Password1,936,String","HKLM:\Software\Test,Password5,shyfzx@163,Binary")

#'de,2c,1b,a7,39,3f,67,08' 加密后的16进制
Function Config-VNCPassword($Password,$ControlPassword,$IsCover=$False){
	Function Set-Pass($Name,$Value16){
		If(!(Test-Path $ItemPath)){$Null=md $ItemPath -Force}
		If([String]::IsNullOrEmpty($Value16)){$Value=$null}Else{$Value=$Value16.split(',')|%{[int32]('0x'+$_)}}
		If(!(gp $ItemPath).$Name -Or $IsCover){sp $ItemPath -Name $Name -Value ([Byte[]][Char[]]$Value) -Type Binary -Force}
	}
	$ItemPath='HKLM:\SOFTWARE\TightVNC\Server'
	Set-Pass -ItemPath $ItemPath -Name Password -Value16 $Password
	Set-Pass -ItemPath $ItemPath -Name ControlPassword -Value16 $ControlPassword
}
Config-VNCPassword '0b,71,0c,49,44,d6,b2,18' '0b,71,0c,49,44,d6,b2,18'