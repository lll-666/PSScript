Function Set-Share([Switch] $enable,[Switch] $disable){
	If(!$enable -and !$disable){throw "Please enter enable or disable"}
	$svcName='LanmanServer'
	$server=Get-Service $svcName -ErrorAction SilentlyContinue
	If($enable){
		If(!$server){throw "There is no shared service in the system , Please install this service first"}
		If($server.StartType -ne 'Automatic'){Set-Service $svcName -StartupType Automatic -ErrorAction SilentlyContinue}
		If($server.status -ne 'Running'){Start-Service $svcName}
	}Else{
		If(!$server){return "There is no shared service in the system , not need oprate"}
		If($server.StartType -ne 'Disabled'){Set-Service $svcName -StartupType Disabled -ErrorAction SilentlyContinue}
		If($server.status -ne 'Stopped'){Stop-Service $svcName}
	}
	Ret-Success
}