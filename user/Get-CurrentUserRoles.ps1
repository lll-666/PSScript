function Get-CurrentUserRoles {
	$SecurityPrinciple = New-Object -TypeName System.Security.Principal.WindowsPrincipal -ArgumentList ([System.Security.Principal.WindowsIdentity]::GetCurrent())
	$RolesHash = @{}
	[System.Enum]::GetNames("System.Security.Principal.WindowsBuiltInRole") | ForEach-Object {
		$RolesHash[$_] =$SecurityPrinciple.IsInRole([System.Security.Principal.WindowsBuiltInRole]::$_)
	}
	$RolesHash
}
Get-CurrentUserRoles