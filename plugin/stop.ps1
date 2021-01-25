Function StopService($name){
	Write-Host "`nStopping service $name"
	Stop-Service $name
	While($true){
		$stop=Get-service $name
		If($stop.status -eq 'Stopped'){Break}
		If($times++ -ge 9){Throw "`nService $name stopped timeout . Please try again later"}
		Sleep 1
	}
	Write-Host "`nService $name stopped successfully"
}

Function StopConnector{
	$fileName='nodeConnectorService.xml'
	$configPath=Join-Path (pwd).path $fileName
	$binPath=Join-Path (pwd).path './nodeConnectorService.exe'
	If(!(Test-Path $configPath)){Write-Warning "`n$fileName file does not exist, please check whether there is $fileName file in the current directory";Return}
	Write-Host "`nReading information from configuration file [$configPath]"
	$xmlData=[xml](Get-Content $configPath);
	$name=$xmlData.configuration.id
	Write-Host "`nThe information for the service is [serviceName:$name]"
	$service=Get-service $name -ErrorAction SilentlyContinue
	If(!$?){
		Write-Host "`nThere is no service named $name in the system, no need operate"
	}Else{
		If($service.status -eq 'Running'){StopService $name}Else{Write-Host "`nService $name has stopped"}
		$null=sc.exe delete $name -ErrorAction SilentlyContinue
	}
}

StopConnector