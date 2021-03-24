Function Black-Software{
	param(
		[String] $hostUrl,
		[String] $softwareName,
		[String] $softwareVersion,
		[bool] $isAuto =$true,
		[String] $processName,
		[String] $serviceName
	);
	$business="[uninstall $softwareName]=>>";
	If([String]::isNullOrEmpty($softwareName)){Return "softwareName can not empty"}
	
	$retVal=Get-SoftwareInfoByNameVersion $softwareName $softwareVersion;
	If($retVal -eq $null){Return Ret-Success "${business}There is no software named $softwareName in the system"}
	If(!$isAuto){Return "There is a prohibited software named $softwareName on the system"}

	If([String]::isNullOrEmpty($retVal.UninstallString)){Return "Uninstall command does not exist, unable to uninstall"}

	If(![String]::isNullOrEmpty($serviceName)){(Set-Serviced $serviceName 'Disabled' 'Stopped')|Foreach{"$business$_"}}

	If(![String]::isNullOrEmpty($processName)){(Set-Processd $processName $False $startFileDir $True)|Foreach{"$business$_"}}

	$UninstallString=$retVal.UninstallString.Trim().ToLower();
	If($UninstallString.StartsWith('msiexec.exe')){
		$msicode=$UninstallString.substring($UninstallString.indexof('{'))
		$Res=OperatorSoftwareByMSI $msicode 'uninstall' $isAuto
	}Else{
		$Res=OperatorSoftwareBySWI $hostUrl $UninstallString $isAuto
	}
	If(!(Is-Success $Res)){Return}

	If((Get-SoftwareInfoByNameVersion $softwareName $softwareVersion) -ne $null){Return Ret-Processing "Uninstallation has not been successful"}
	Return Ret-Success $business
}