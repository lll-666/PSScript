$env:PSExecutionPolicyPreference='Unrestricted'
$currentWp = [Security.Principal.WindowsPrincipal]([Security.Principal.WindowsIdentity]::GetCurrent())
If( -not $currentWp.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){
	throw 'Please use the administrator to run the app'
}
$ErrorActionPreference='Continue';
If(@('Unrestricted','RemoteSigned') -notcontains ((Get-ExecutionPolicy -Scope CurrentUser).tostring())){Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted -Force;}
If(@('Unrestricted','RemoteSigned') -notcontains ((Get-ExecutionPolicy -Scope LocalMachine).tostring())){Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy Unrestricted -Force;}
([Activator]::CreateInstance([Type]::GetTypeFromCLSID("DCB00C01-570F-4A9B-8D69-199FDBA5723B"))).GetNetworks(1)|%{$_.SetCategory(0x01)};
If([Environment]::OSVersion.version.Major -eq 6){
	Restart-service mpssvc;
	WinRm quickconfig -q;
}ElseIf($PSVersionTable.PSVersion.Major -ge 5){
	cmd /c 'winrm set winrm/config/Listener?Address=*+Transport=HTTP @{Enabled="true"}'
	If(!$?){
		([Activator]::CreateInstance([Type]::GetTypeFromCLSID("DCB00C01-570F-4A9B-8D69-199FDBA5723B"))).GetNetworks(1)|%{$_.SetCategory(0x00)};
		([Activator]::CreateInstance([Type]::GetTypeFromCLSID("DCB00C01-570F-4A9B-8D69-199FDBA5723B"))).GetNetworks(1)|%{$_.SetCategory(0x01)};
		cmd /c 'winrm set winrm/config/Listener?Address=*+Transport=HTTP @{Enabled="true"}'
	}
}