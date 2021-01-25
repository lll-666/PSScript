#兼容到xp
Function Get-OsVersion{
	<#
	$os=Get-WmiObject -Class Win32_OperatingSystem
	If($os -eq $Null){Throw "The operating system is empty"}
	If($os.version -eq $Null){Throw "The operating system version information is empty"}
	$vers=$os.version.split('.')
	Return New-Object PSObject -Property @{Major=$vers[0];Minor=$vers[1];Build=$vers[2]}
	#>
	<#
	#PS版本
		[Environment]::Version	
		$host.Version
		$PSVersionTable.PSVersion
	#>
	<#
	操作系统内核版本
		[Environment]::OSVersion.version	
		$PSVersionTable.BuildVersion
	#>
	Return $PSVersionTable.BuildVersion
}