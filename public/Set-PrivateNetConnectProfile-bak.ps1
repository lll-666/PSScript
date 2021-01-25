$ErrorActionPreference='Continue';
$WarningPreference='Continue';
If(@('Unrestricted','RemoteSigned') -notcontains ((Get-ExecutionPolicy -Scope CurrentUser).tostring())){Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted -Force;}
If(@('Unrestricted','RemoteSigned') -notcontains ((Get-ExecutionPolicy -Scope LocalMachine).tostring())){Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy Unrestricted -Force;}
$currentWp = [Security.Principal.WindowsPrincipal]([Security.Principal.WindowsIdentity]::GetCurrent())
If( -not $currentWp.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){
    $boundPara = ($MyInvocation.BoundParameters.Keys | Foreach{'-{0} {1}' -f  $_ ,$MyInvocation.BoundParameters[$_]} ) -join ' '
    $currentFile = $MyInvocation.MyCommand.Definition
    $fullPara = $boundPara + ' ' + $args -join ' '
	Write-Warning 'You did not use an administrator to execute this script. the system is trying to use administrative execution...'
    start "$psHome\powershell.exe"   -ArgumentList "$currentFile $fullPara"   -verb runas  -WindowStyle Hidden
	echo '';Write-Host 'Finished using administrator...'
    Return
}
If([Environment]::OSVersion.version.Major -eq 6){
	([Activator]::CreateInstance([Type]::GetTypeFromCLSID('DCB00C01-570F-4A9B-8D69-199FDBA5723B'))).GetNetworks(1)|%{$_.SetCategory(0x01)};
	Restart-service mpssvc;
	WinRm quickconfig -q;
}ElseIf($PSVersionTable.PSVersion.Major -ge 5){
	Set-NetConnectionProfile -NetworkCategory private;
	cmd /c 'winrm set winrm/config/Listener?Address=*+Transport=HTTP @{Enabled="true"}'
	If(!$?){
		Set-NetConnectionProfile -NetworkCategory public;
		Set-NetConnectionProfile -NetworkCategory private;
		cmd /c 'winrm set winrm/config/Listener?Address=*+Transport=HTTP @{Enabled="true"}'
	}
}

cmd /c 'reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell" /v ExecutionPolicy /t REG_SZ /d Unrestricted /f'