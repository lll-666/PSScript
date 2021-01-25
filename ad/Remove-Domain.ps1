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
Function Remove-Domain([String]$username,[String]$password,[String]$Group){
	If([String]::IsNullOrEmpty($username)){
		Return "UserName cannot be empty";
	}
	If([String]::IsNullOrEmpty($password)){
		$credential=$username
	}Else{
		$credential=Get-PSCredentials $username $password
	}
	$WarningPreference='SilentlyContinue'
	$ErrorActionPreference='SilentlyContinue'
	Remove-Computer -Credential $credential -Force;
	If(!$?){Return "Remove-Computer Exception,The Exception is $($error[0])"}
	Return 'Remove-Computer %%SMP:success'
}
$res=Remove-Domain -username rj.com\administrator -password shyfzx@163
Unified-Return $res 'Remove-Computer'