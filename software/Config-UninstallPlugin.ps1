Function Config-Plugin{
	Param(
		[String]$userName=$null,
		[String]$password=$null,
		[String]$uninstallPassword=$null,
		[String]$canUninstallPlugin='false'
	)
	$installDir=$env:ProgramFiles
	If([IntPtr]::Size -eq 8){$installDir+=' (x86)'}
	$configPath=Join-Path $installDir 'Ruijie Networks/uninstallPlugin'
	$hashtable = @{}
	If(Test-Path $configPath){
		cat -Path $configPath|?{ $_ -like '*=*' }|%{
			$info = $_ -split '='
			$hashtable.$($info[0].Trim()) = $info[1].Trim()
		}
		clc $configPath
	}
	$ParameterList = (gcm -Name $MyInvocation.InvocationName).Parameters
	Foreach ($key in $ParameterList.keys){
		$var = gv $key -ErrorAction SilentlyContinue;
		If($var){If(![String]::IsNullOrEmpty($var.value)){$hashtable.$key=$var.value}}
	}
	Foreach($key in $hashtable.Keys){"$key=$($hashtable.$key)">>$configPath}
}