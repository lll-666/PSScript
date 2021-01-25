Function Unified-Return([Object[]]$msgs,[Parameter(Mandatory = $true)][String]$business){
	If($msgs -eq $Null -Or $msgs.count -eq 0){
		$isSuccess='false';
		$msg='No message returned';
	}Else{
		If(($msgs[-1]).EndsWith('%%SMP:success')){
			$isSuccess='true';
		}else{
			$isSuccess='false';
		}
		$msg=$msgs -Join ';	'
	}
	Return "{`"isSuccess`":`"$isSuccess`",`"msg`":`"$msg`",`"business`":`"$business`"}";
}

Function Get-PSCredentials([Parameter(Mandatory = $true)][String]$username,[Parameter(Mandatory = $true)][String]$password){
	$credential=ConvertTo-SecureString $Password -asPlainText -Force
	Return New-Object System.Management.Automation.PSCredential($username,$credential)
}

Function Add-Domain{
	param(
		[Parameter(Mandatory = $true)] [string] $Domain,
		[Parameter(Mandatory = $true)][Object[]] $MainDNS,
		[string] $Password,
		[string] $UserName
	)
	$WarningPreference='SilentlyContinue';
	$ErrorActionPreference='SilentlyContinue';
	#设置dns
	$DNS=Get-WmiObject win32_networkadapterconfiguration -filter "ipenabled = 'true'"
	$Null=$DNS.SetDNSServerSearchOrder($MainDNS)
	If(!$?){Return "SetDNSServer Exception,The Exception is $($error[0])"}
	$comp=Get-WmiObject Win32_ComputerSystem;
	If($Domain -eq $comp.Domain -And $comp.PartOfDomain){
		Return "This $($comp.Name) has joined the domain %%SMP:success"
	}
	#兼容性处理
	$version=(Get-WmiObject -Class Win32_OperatingSystem).version;
	$isLowerVersion=([Double]$version.substring(0,$version.indexof('.',3))) -le 6.2
	If($isLowerVersion){$UserName=$Domain.ToLower().Replace('.com','')+'\'+$UserName}
	
	$credential=Get-PSCredentials $UserName $Password
	#加入域
	#存在兼容问题，在winserver2016有问题，在win10,win7没问题
	If($isLowerVersion){
		$null=Add-Computer -DomainName $Domain  -Credential $credential
	}else{
		$null=Add-Computer -DomainName $Domain  -Credential $credential -Force
	}
	If(!$?){Return "The Exception is $($error[0])"}
	Return '%%SMP:success'
}
$res=Add-Domain -Domain rj.com -MainDNS @('172.17.8.179','8.8.8.8','114.114.114.114') -UserName administrator -Password shyfzx@163
Unified-Return $res 'Add-Computer'