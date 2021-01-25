$currentWp = [Security.Principal.WindowsPrincipal]([Security.Principal.WindowsIdentity]::GetCurrent())
If(-not $currentWp.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){
	Write-Warning 'You did not use an administrator to execute this script. the system is trying to use administrative execution...'
	Start-Process "$psHome\powershell.exe" -verb runas -WindowStyle Hidden
	echo '';Write-Host 'Finished using administrator...'
	return
}
Function Write-ERR($msg){Write-Host "ERROR: $msg" -ForegroundColor red -BackgroundColor white}
Function Write-SUC($msg){Write-Host "SUEECESS: $msg" -ForegroundColor Green -BackgroundColor white}
If(Test-Path "$($env:SystemDrive)\Program Files (x86)\Asiainfo Security\OfficeScan Client\PccNTMon.exe"){
	$startFile="$($env:SystemDrive)\Program Files (x86)\Asiainfo Security\OfficeScan Client\PccNTMon.exe"
}ElseIf(Test-Path "$($env:SystemDrive)\Program Files\Asiainfo Security\OfficeScan Client\PccNTMon.exe"){
	$startFile="$($env:SystemDrive)\Program Files\Asiainfo Security\OfficeScan Client\PccNTMon.exe"
}Else{Write-ERR "The process startup file does not exist , so cannot start process";Return}
$processName='PccNTMon'
$pro=Get-Process $processName -ErrorAction SilentlyContinue;
If($pro -ne $null){Write-SUC "$processName is already running , No Need Operator";Return}
Start $startFile -ErrorAction SilentlyContinue
If(!$?){Write-ERR "Start [$startFile] faile";Return}
Write-SUC "Has successfully pulled up $processName"