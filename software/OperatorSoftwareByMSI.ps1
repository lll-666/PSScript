Function OperatorSoftwareByMSI{
	param(
		[String]$softwarePath,
		[ValidateSet('install','uninstall')]$method,
		$isSilent=$false
	)
	If([String]::IsNullOrEmpty("$softwarePath")){
		Return "Executable file [${softwarePath}] does not exist"
	}
	$business="OperatorSoftwareByMSI of `"$softwarePath`""
	$power=gwmi Win32_Process|?{$_.ProcessName -eq "msiexec.exe"}|%{ps -id $_.ParentProcessId -ErrorAction SilentlyContinue}|?{$_.name -eq 'cmd'}
	If($power -ne $null){Return Ret-Processing "$softwarePath is Installing"}
	If($silent){
		$command="& cmd /c `'msiexec.exe /$method `"$softwarePath`"`' /norestart /qn ADVANCED_OPTIONS=1 CHANNEL=100"
	}Else{
		$command="& cmd /c `'msiexec.exe /$method `"$softwarePath`"`' /norestart ADVANCED_OPTIONS=1 CHANNEL=100"
	}
	$null=iex $command -ErrorAction SilentlyContinue
	If(!$?){Return Print-Exception $business}
	Return Ret-Success $business
}