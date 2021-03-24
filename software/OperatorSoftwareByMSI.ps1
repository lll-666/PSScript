Function OperatorSoftwareByMSI{
	param(
		[String]$softwarePath,
		[ValidateSet('install','package','i','uninstall','x')]$method,
		$isSilent=$false
	)
	If([String]::IsNullOrEmpty("$softwarePath")){
		Return "Executable file [${softwarePath}] does not exist"
	}
	$business="OperatorSoftwareByMSI of `"$softwarePath`""
	$power=gwmi Win32_Process|?{$_.ProcessName -eq "msiexec.exe"}|%{ps -id $_.ParentProcessId -ErrorAction SilentlyContinue}|?{$_.name -eq 'cmd'}
	If($power -ne $null){Return Ret-Processing "$softwarePath is Installing"}
	
	If(@('install','package','i') -contains $method){
		$command="& cmd /c `'msiexec.exe /i `"$softwarePath`"`' /norestart /qn ADVANCED_OPTIONS=1 CHANNEL=100"
	}Elseif(@('uninstall','x') -contains $method){
		$command="& cmd /c `'msiexec.exe /x `"$softwarePath`"`' /norestart ADVANCED_OPTIONS=1 CHANNEL=100"
	}Else{Return 'Method not supported'}
	
	$null=iex $command -ErrorAction SilentlyContinue
	If(!$?){Return Print-Exception $business}
	Return Ret-Success $business
}