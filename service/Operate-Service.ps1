$serviceName='~serviceName~';
$startType='~startType~';
$displayName='~displayName~';
$status='~status~';
$description='~description~';

If($startType -like '~startType*'){$startType=''}
If($displayName -like '~displayName*'){$displayName=''}
If($status -like '~status*'){$status=''}
If($description -like '~description*'){$description=''}
If($serviceName -like '~serviceName*'){$serviceName=''}

If([String]::isNullOrEmpty($serviceName)){
	Return "BusinessException:serviceName can not empty"
}

Function PrintException($command){Return "execute Command [$command] Exception,The Exception is $($error[0])"}

Get-Service $serviceName -ErrorAction SilentlyContinue
If(!$?){Return PrintException "Get-Service $serviceName"}

#Boot|System|Automatic|Manual|Disabled
If(![String]::isNullOrEmpty($startType)){
	Try{
		Set-Service $serviceName -StartupType $startType
	}Catch{
		Return PrintException "Set-Service $serviceName -StartupType $startType"
	}
}

If(![String]::isNullOrEmpty($displayName)){
	Try{
		Set-Service $serviceName -DisplayName $displayName
	}Catch{
		Return PrintException "Set-Service $serviceName -DisplayName $displayName"
	}
}

If(![String]::isNullOrEmpty($description)){
	Try{
		Set-Service $serviceName -Description $description
	}Catch{
		Return PrintException "Set-Service $serviceName -Description $description"
	}
}

#Running|Stopped|Paused
If(![String]::isNullOrEmpty($status)){
	Set-Service $serviceName -Status $status -ErrorAction SilentlyContinue
	If(!$?){Return PrintException "Set-Service $serviceName -Status $status"}
}

Write-Host "%%SMP:success";