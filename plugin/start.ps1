Function RegistService($name){
	Write-Host "`nRegistering service $name"
	New-Service -Name $name -BinaryPathName $binPath -DisplayName $disPlayName -Description $description -StartupType Automatic -ErrorAction SilentlyContinue
	If(!$?){Throw "Failed to register service $name , The exception information is {$($error[0])}"}
	Write-Host "`nsuccessfully registered service $name"
}

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

Function StartService($name){
	Write-Host "`nStarting service $name"
	Start-Service $name -ErrorAction SilentlyContinue
	If(!$?){return "`nService $name start failed , The exception information is {$($error[0])}"}
	Set-Service $name -StartupType Automatic -ErrorAction SilentlyContinue
	While($true){
		$start=Get-service $name
		If($start.status -eq 'Running'){Break}
		If($times++ -ge 9){Throw "`nService $name started timeout . Please try again later"}
		Sleep 1
	}
	Write-Host "`nService $name started successfully"
}

Function StartConnector{
	$fileName='nodeConnectorService.xml'
	$configPath=Join-Path (pwd).path $fileName
	$binPath=Join-Path (pwd).path './nodeConnectorService.exe'
	If(!(Test-Path $configPath)){Write-Warning "`n$fileName file does not exist, please check whether there is $fileName file in the current directory";Return}
	Write-Host "`nReading information from configuration file [$configPath]"
	$xmlData=[xml](Get-Content $configPath);
	$name=$xmlData.configuration.id
	$disPlayName=$xmlData.configuration.name
	$description=$xmlData.configuration.description
	Write-Host "`nThe information for the service is [serviceName:$name , serviceDisplayName:$disPlayName , serviceDescription:$description]"
	$service=Get-service $name  -ErrorAction SilentlyContinue
	If(!$?){
		Write-Host "`nThere is no service named $name in the system"
		RegistService $name
		StartService $name
	}Else{
		If($service.status -eq 'Running'){StopService $name}
		StartService $name
	}
}

StartConnector