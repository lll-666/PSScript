$startType='~startType~';
$serviceName='~name~';
$displayName='~displayName~';
$serviceStatus='~Status~';
$description='~desc~';

if([String]::isNullOrEmpty($serviceName)){
	Write-Host "BusinessException:serviceName can not empty";	
	return
}

if(![String]::isNullOrEmpty($startType)){
	Try{
		Set-Service $serviceName -StartupType $startType
	}Catch{
		Write-Host "execute Command [Set-Service $serviceName -StartupType $startType] Exception,The Exception is $($error[0])";
		return
	}
}

if(![String]::isNullOrEmpty($serviceStatus)){
	Try{
		Set-Service $serviceName -Status $serviceStatus
	}Catch{
		Write-Host "execute Command [Set-Service $serviceName -Status $serviceStatus] Exception,The Exception is $($error[0])";
		return
	}
}

if(![String]::isNullOrEmpty($displayName)){
	Try{
		Set-Service $serviceName -DisplayName $displayName
	}Catch{
		Write-Host "execute Command [Set-Service $serviceName -DisplayName $displayName] Exception,The Exception is $($error[0])";
		return
	}
}

if(![String]::isNullOrEmpty($description)){
	Try{
		Set-Service $serviceName -Description $description
	}Catch{
		Write-Host "execute Command [Set-Service $serviceName -Description $description] Exception,The Exception is $($error[0])";
		return
	}
}

