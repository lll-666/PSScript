$ProcessName='~ProcessName~';

Get-Process -Name $ProcessName -ErrorAction "SilentlyContinue";
If (!$?){
	Write-Host "%%SMP:$ProcessName of process not exist";
	return
}
Write-Host "%%SMP:success";