$currentWp = [Security.Principal.WindowsPrincipal]([Security.Principal.WindowsIdentity]::GetCurrent())
If(-not $currentWp.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){
	Write-Warning 'You did not use an administrator to execute this script. the system is trying to use administrative execution...'
	Start "$psHome\powershell.exe" -verb runas -WindowStyle Hidden
	echo '';Write-Host 'Finished using administrator...'
	return
}
Function Write-ERR($msg){Write-Host "ERROR: $msg" -ForegroundColor red -BackgroundColor white}
Function Write-SUC($msg){Write-Host "SUEECESS: $msg" -ForegroundColor Green -BackgroundColor white}
$processName='PccNTMon'
$pro=Get-Process $processName -ErrorAction SilentlyContinue;
If($pro -ne $null){Write-SUC "$processName is already stopped , No Need Operator";Return}
Stop-Process -id $pro.id -ErrorAction SilentlyContinue
If(!$?){Write-ERR "stop [$startFile] fail";Return}
Write-SUC "Has successfully stopped $processName"