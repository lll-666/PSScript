Function Get-ServiceExecuteFilePath($name){
	$SerObj=gwmi win32_service|?{$_.Name -like "*${name}*"}
	If($SerObj -ne $Null){
		$Path=$SerObj.PathName
		$Len=$Path.IndexOf('.exe')
		If($Len -ne -1){$Path=$Path.substring(0,$Len+4)}
		If($Path.StartsWith('"')){$Path=$Path.subString(1)}
		If($Path.EndsWith('"')){$Path=$Path.subString(0,$Path.length-1)}
		Return $Path
	}
}