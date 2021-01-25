Function Get-InstalledSoftware{
	Function Get-KeyValFromReg($Hive,$regPath,$retPro){
		$RegHive=[Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($Hive,$env:COMPUTERNAME)
		$RegKey=$RegHive.OpenSubKey($regPath)
		If([string]::IsNullOrEmpty($RegKey)){Return}
		$RegKey.GetSubKeyNames()|ForEach{
			$SubKey=$RegKey.OpenSubKey($_)
			$retVal=1|select -Property $retPro
			ForEach($_ in $retPro){
				$tmp=$subkey.GetValue($_)
				If(![string]::IsNullOrEmpty($tmp)){
					If($tmp.gettype().name -eq 'string'){$retVal.$_=($tmp -replace [Regex]::UnEscape('\u0000'), '').Replace('"','').Replace('\','/')
					}ElseIf($tmp.gettype().name -eq 'int32'){$retVal.$_=$tmp}
				}
			}
			If(![string]::IsNullOrEmpty($SubKey.GetValue('DisplayName'))){
				$retVal.RegPath=($SubKey.Name -replace [Regex]::UnEscape('\u0000'), '').Replace('"','').Replace('\','/');$retVal
			}
			$SubKey.Close()
		}
		$RegHive.Close()
	}
	$Value='DisplayName','DisplayVersion','UninstallString','InstallLocation','RegPath','EstimatedSize','InstallDate','InstallSource','Language','ModifyPath','Publisher','icon'
	$List=Get-KeyValFromReg LocalMachine SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall $Value
	$List+=Get-KeyValFromReg CurrentUser Software\Microsoft\Windows\CurrentVersion\Uninstall $Value
	If([IntPtr]::Size -eq 8){$List+=Get-KeyValFromReg LocalMachine SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall $Value}
	Return $List
}