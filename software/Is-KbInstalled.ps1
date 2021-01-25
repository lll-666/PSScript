Function Is-KbInstalled($kbNum){
	$Key='SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages';
	$RegHive=[Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine',$env:COMPUTERNAME);
	$RegKey=$RegHive.OpenSubKey($Key);
	If([string]::IsNullOrEmpty($RegKey)){return $false}
	$parttern="Package_for_KB$kbNum~[a-zA-Z0-9]*~[a-zA-Z0-9]*~~"
	$ret=$false;
	$matched=$false;
	$RegKey.GetSubKeyNames()|ForEach{
		if($_ -match $parttern){
			$matched=$true
			$SubKey=$RegKey.OpenSubKey($_);
			$tmp=$subkey.GetValue('CurrentState');
			$SubKey.Close()
			if($tmp.gettype().name -eq 'int32'){
				if($tmp -eq 0x70 -or $tmp -eq 0x60  -or $tmp -eq 0x65 ){
				$ret=$true
				}
			}
		}
	}
	if(!$matched){
		$parttern="Package_for_KB"+$kbNum +"_RTM~[a-zA-Z0-9]*~[a-zA-Z0-9]*~~"
		$RegKey.GetSubKeyNames()|ForEach{
			if($_ -match $parttern){
				$SubKey=$RegKey.OpenSubKey($_);
				$tmp=$subkey.GetValue('CurrentState');
				$SubKey.Close()
				if($tmp.gettype().name -eq 'int32'){
					if($tmp -eq 0x70 -or $tmp -eq 0x60  -or $tmp -eq 0x65 ){
						$ret=$true
					}
				}
			}
		}
	}
	$RegHive.Close()
	return $ret;
}