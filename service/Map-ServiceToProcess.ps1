$serviceName='tvnserver'
Function Get-ProcessByService($serviceName){
	$service=gwmi win32_service | ?{$_.name -eq $serviceName}|select name,pathname
	gwmi Win32_Process | ?{$_.CommandLine -eq "$($service.pathname)"}|select name,processId,path
}