Function Get-SoftwareInfoByNameVersion([String] $name,[String] $version){
	$Key='Software\Microsoft\Windows\CurrentVersion\Uninstall','SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall';
	If([IntPtr]::Size -eq 8){$Key+='SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'}
	Foreach($_ In $Key){
	  $Hive='LocalMachine';
	  If('Software\Microsoft\Windows\CurrentVersion\Uninstall' -ceq $_){$Hive='CurrentUser'}
	  $RegHive=[Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($Hive,$env:COMPUTERNAME);
	  $RegKey=$RegHive.OpenSubKey($_);
	  If([string]::IsNullOrEmpty($RegKey)){Continue}
	  $arrs=$RegKey.GetSubKeyNames();
	  Foreach($_ In $arrs){
		$SubKey=$RegKey.OpenSubKey($_);
		$tmp=$subkey.GetValue('DisplayName');
		If(![string]::IsNullOrEmpty($tmp)){
			$tmp=$tmp.Trim();
			If($tmp.gettype().name -eq 'string' -And $tmp -like $name){
				$DisplayVersion=$subkey.GetValue('DisplayVersion');
				If(![string]::IsNullOrEmpty($version) -and $version -notlike $DisplayVersion){Continue}
				$retVal=''|Select 'DisplayName','DisplayVersion','UninstallString','InstallLocation','RegPath','InstallDate','InstallSource';
				$retVal.DisplayName=$subkey.GetValue('DisplayName');
				$retVal.DisplayVersion=$DisplayVersion;
				$retVal.UninstallString=$subkey.GetValue('UninstallString');
				$retVal.InstallLocation=$subkey.GetValue('InstallLocation');
				$retVal.RegPath=$subkey.GetValue('RegPath');
				$retVal.InstallDate=$subkey.GetValue('InstallDate');
				$retVal.InstallSource=$subkey.GetValue('InstallSource');
				Return $retVal;
			}
		}
		$SubKey.Close()
	  };
	  $RegHive.Close()
	};
}