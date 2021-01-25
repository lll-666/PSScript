Function Set-Serviced([String]$serviceName,[String]$startType,[String]$status){
	$business="[Set-Serviced $serviceName]=>>"
	If([String]::IsNullOrEmpty($serviceName)){Return "$business The serviceName can not empty"}
	$service=Get-Service $serviceName -ErrorAction SilentlyContinue;
	If(!$?){
		If($error[0].ToString() -like '*Cannot find any service*'){
			If('Stopped' -eq $status){Return "Cannot find any service with service name ${serviceName} %%SMP:success"}
		}
		Return Print-Exception "${business}Get-Service $serviceName"
	}
	#StartupType:[Boot|System|Automatic|Manual|Disabled],Status:[Running|Stopped|Paused]
	if(![String]::IsNullOrEmpty($startType) -And $service.StartType -ne $startType){
		Set-Service $serviceName -StartupType $startType -ErrorAction SilentlyContinue;
	}
	If(![String]::IsNullOrEmpty($status) -And $service.status -ne $status){
		If('Running' -eq $service.status){
			Stop-Service $serviceName -Force -ErrorAction SilentlyContinue;
			If(!$?){Return Print-Exception "Stop-Service $serviceName -Force"}
		}Else{
			Start-Service $serviceName -ErrorAction SilentlyContinue;
			If(!$?){Return Print-Exception "Start-Service $serviceName"}
		}
	}
	Return Ret-Success $business
}