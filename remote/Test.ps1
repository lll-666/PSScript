Function White-Software{
	param([String] $hostUrl,
		[String] $softwareName,
		[String] $softwareVersion64,
		[String] $fileName64,
		[String] $softwareVersion32,
		[String] $fileName32,
		[bool] $silent=$true
	)
	If([String]::isNullOrEmpty($softwareName)){Return "BusinessException:softwareName can not empty"}
	If([String]::isNullOrEmpty($hostUrl)){Return "BusinessException:hostUrl can not empty"}
	If([String]::isNullOrEmpty($fileName64) -and [String]::isNullOrEmpty($fileName32)){Return "BusinessException:install package can not empty"}
	
	$downloadPath = Join-Path $env:SystemDrive '/Program Files/Ruijie Networks/softwarePackage/';
	If(!(Test-Path $downloadPath)){mkdir $downloadPath -Force|Out-Null}
	If([IntPtr]::Size -eq 4){
		If([String]::isNullOrEmpty($fileName32)){Return Ret-Success "no installation package32 available, default and pass"}
		$softwareVersion=$softwareVersion32;
		$bit='bit32';
		$fileName=$fileName32
	}Else{
		If([String]::isNullOrEmpty($fileName64)){Return Ret-Success "no installation package64 available, default and pass"}
		$softwareVersion=$softwareVersion64;
		$bit='bit64';
		$fileName=$fileName64;
	}
	If(Test-Path "$($env:SystemDrive)\Program Files (x86)\TightVNC\tvnserver.exe") {
		$startFile="$($env:SystemDrive)\Program Files (x86)\TightVNC\tvnserver.exe"
	}ElseIf(Test-Path "$($env:SystemDrive)\Program Files\TightVNC\tvnserver.exe") {
		$startFile="$($env:SystemDrive)\Program Files\TightVNC\tvnserver.exe"
	}
	$pass='15-224-193-197-37-128-73-235'
	Config-TightVNC -RegPath 'HKLM:\SOFTWARE\TightVNC\Server' -Password $pass -ControlPassword $pass -PasswordViewOnly $pass
	Config-TightVNC -RegPath 'HKCU:\SOFTWARE\TightVNC\Server' -Password $pass -ControlPassword $pass -PasswordViewOnly $pass
	If((Get-SoftwareInfoByNameVersion $softwareName $softwareVersion) -ne $null){		
		If(gsv tvnserver -ErrorAction SilentlyContinue){		
			Restart-Service tvnserver -ErrorAction SilentlyContinue;
			If($?){Return Ret-Success}
		}
	}
	
	$softwarePath = Join-Path $downloadPath $fileName;
	If(!(Test-Path "$softwarePath") -or (cat "$softwarePath" -TotalCount 1) -eq $null){
		$tmp=Handle-SpecialCharactersOfHTTP "?fileName=$fileName&dir=win/$bit";
		$remoteSoftwarePath=$hostUrl+'/temp'+$tmp;
		$Res=Download-File "$remoteSoftwarePath" "$softwarePath";"$Res";
		If(!(Is-Success $Res)){Return}
	}
	
	$file=ls $softwarePath;
	If($null -ne (ps|?{$_.name -eq $file.baseName -And ($_.path -eq $null -Or $_.path -eq $softwarePath)})){Return "$($file.name) is Installing"}
	
	If('.msi' -eq $file.Extension){
		If($silent){
			iex "& cmd /c `'msiexec.exe /i `"$softwarePath`"`' /norestart /qn ADVANCED_OPTIONS=1 CHANNEL=100"
		}Else{
			iex "& cmd /c `'msiexec.exe /i `"$softwarePath`"`' ADVANCED_OPTIONS=1 CHANNEL=100"
		}
		If(!$?){Return Print-Exception "Msiexec /i `"$softwarePath`" /norestart /qn"}
	}else{
		$Res=OperatorSoftwareBySWI $hostUrl $softwarePath $silent;"$Res";
		If(!(Is-Success $Res)){Return}
	}
	If((Get-SoftwareInfoByNameVersion $softwareName $softwareVersion) -eq $null){Return "BusinessException:Installation of the software has not been successful"}
	Restart-Service tvnserver -ErrorAction SilentlyContinue;
	If($?){Return Ret-Success}
};Function Config-TightVNC{
	Param(
		[Parameter(Mandatory=$true)]$RegPath,[bool]$IsReplace=$True,[String]$Password,[String]$ControlPassword,[String]$PasswordViewOnly,
		[String]$QueryTimeout,[String]$ExtraPorts,[String]$QueryAcceptOnTimeout,[String]$LocalInputPriorityTimeout,[String]$LocalInputPriority,
		[String]$BlockRemoteInput,[String]$BlockLocalInput,[String]$IpAccessControl,[String]$RfbPort,[String]$HttpPort,[String]$DisconnectAction,
		[String]$AcceptRfbConnections,[String]$UseVncAuthentication,[String]$UseControlAuthentication,[String]$RepeatControlAuthentication,
		[String]$LoopbackOnly,[String]$AcceptHttpConnections,[String]$LogLevel,[String]$EnableFileTransfers,[String]$RemoveWallpaper,[String]$UseMirrorDriver,
		[String]$EnableUrlParams,[String]$AlwaysShared,[String]$NeverShared,[String]$DisconnectClients,[String]$PollingInterval,[String]$AllowLoopback,
		[String]$VideoRecognitionInterval,[String]$GrabTransparentWindows,[String]$SaveLogToAllUsersPath,[String]$RunControlInterface
	)
		
	$DefautV=@{
		Password='Binary:@(15,224,193,197,37,128,73,235)';ControlPassword='Binary:@(15,224,193,197,37,128,73,235)';PasswordViewOnly='Binary:@(15,224,193,197,37,128,73,235)';
		QueryTimeout='Dword:30';ExtraPorts='String:';QueryAcceptOnTimeout='Dword:0';
		LocalInputPriorityTimeout='Dword:3';LocalInputPriority='Dword:0';BlockRemoteInput='Dword:0';
		BlockLocalInput='Dword:0';IpAccessControl='String:';RfbPort='Dword:5900';
		HttpPort='Dword:5800';DisconnectAction='Dword:0';AcceptRfbConnections='Dword:1';
		UseVncAuthentication='Dword:1';UseControlAuthentication='Dword:1';RepeatControlAuthentication='Dword:0';
		LoopbackOnly='Dword:0';AcceptHttpConnections='Dword:1';LogLevel='Dword:0';
		EnableFileTransfers='Dword:1';RemoveWallpaper='Dword:1';UseMirrorDriver='Dword:1';
		EnableUrlParams='Dword:1';AlwaysShared='Dword:0';NeverShared='Dword:0';
		DisconnectClients='Dword:1';PollingInterval='Dword:1000';AllowLoopback='Dword:0';
		VideoRecognitionInterval='Dword:3000';GrabTransparentWindows='Dword:1';SaveLogToAllUsersPath='Dword:0';
		RunControlInterface='Dword:1'
	}
	
	If(!(Test-Path $RegPath)){$null=md $RegPath -Force -ErrorAction SilentlyContinue}
	$reg=gi $RegPath
	$pks=$PSBoundParameters.keys
	Foreach($pk in $pks){
		$dm=$DefautV.$pk
		If(!$dm){Continue}
		$DefautV.remove($pk)
		$pv=$PSBoundParameters[$pk]
		$rv=$reg.GetValue($pk)
		$dt=$dm.split(':')[0]
		If('Binary' -eq $dt){
			If($rv -eq $null){$rv=''}
			If($pv -eq ($rv -join '-')){Continue}
			$pv=$pv.split('-')
		}Else{If($pv -eq $rv){Continue}}
		If($IsReplace){sp $RegPath -Name $pk -Value $pv -Type $dt}
	}
	
	$dks=$DefautV.keys
	Foreach($dk in $dks){
		If($reg.GetValue($dk)){Continue}
		$str=$DefautV.$dk
		$arr=$str.split(':')
		If($arr.count -ne 2){continue}
		$dt=$arr[0]
		$dv=$arr[1]
		If('Binary' -eq $dt){$dv=iex "$($arr[1])"}
		sp $RegPath -Name $dk -Value $dv -Type $dt
		$IsChange=$true
	}
	If(gsv tvnserver -ErrorAction SilentlyContinue){Restart-Service tvnserver}
};Function Ret-Success([String] $business){
	Return "$business%%SMP:success"
};Function Is-Success($Ret){
	If($Ret -ne $null -And ($Ret|Select -Last 1).EndsWith('%%SMP:success')){Return $True}
	Return $False
};Function Print-Exception([String]$command){
	Return "execute Command [$command] Exception,The Exception is $($error[0])"
};Function Download-File([String]$src,[String]$des,[bool]$isReplace=$false){
	If([String]::IsNullOrEmpty($src)){Return "BusinessException:Source file does not exist"}
	If([String]::IsNullOrEmpty($des)){Return "BusinessException:Destination address cannot be empty"}
	If(Test-Path $des){
		while (Test-FileLocked $des){
			sleep 1;
			If($i++ -gt 1){Return "File [$des] is in use"}
		}
		$file=ls $des;
		If(Test-Path ($file.DirectoryName+"/"+$file.basename+"_end")){Return Ret-Success "Download-File:No Need Operator"}
	}
	Try{
		$web=New-Object System.Net.WebClient;
		$web.Encoding=[System.Text.Encoding]::UTF8;
		$web.DownloadFile("$src", "$des");
		$file=(ls $des);
		$endFile=$file.basename+"_end";
		New-Item -Path $file.DirectoryName -Name $endFile -ItemType "file" |Out-Null
		If(!(Test-Path $des) -or (Get-Content "$des" -totalcount 1) -eq $null){Return "BusinessException:The downloaded file does not exist or the content is empty"}
	}Catch{Return Print-Exception "$web.DownloadFile($src,$des)"}
	Return Ret-Success "Download-File"
};Function Get-SoftwareInfoByNameVersion([String] $name,[String] $version){
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
};Function OperatorSoftwareBySWI([String]$hostUrl,[String]$softwarePath,$isSilent=$True){
	$business="[OperatorSoftwareBySWI:$softwarePath]=>>"
	If([String]::IsNullOrEmpty("$softwarePath")){
		Return "uninstall script not exist"
	}
	If(!$softwarePath.EndsWith(".exe") -And !$softwarePath.EndsWith(".exe`"")){
		Return "uninstall script format error[$softwarePath]"
	}
	If($softwarePath.StartsWith('"')){
		$softwarePath=$softwarePath.substring(1,$softwarePath.LastIndexOf('"'))
	}
	$SWIDir=Join-Path $env:SystemRoot 'System32';
	If(!(Test-Path $SWIDir)){
		mkdir $SWIDir -Force|Out-Null;
		If(!$?){Return Print-Exception "${business}mkdir $SWIDir -Force|Out-Null"}
	}
	
	If([IntPtr]::Size -eq 8){$SWIFileName='SWIService64.exe'}Else{$SWIFileName='SWIService.exe';}
	$SWIPath=Join-Path $SWIDir $SWIFileName;
	$SWIServiceName='SWIserv';
	If (!(Test-Path "$SWIPath")){
		If([String]::IsNullOrEmpty("$hostUrl")){Return "When downloading the installation package, the host address cannot be empty"}
		$remoteexePath="$hostUrl/$SWIFileName";
		$Res=Download-File "$remoteexePath" "$SWIPath";"$business$Res";
		If(!(Is-Success $Res)){Return}
	}
	
	Restart-Service $SWIServiceName -ErrorAction SilentlyContinue;
	If(!$?){
		Try{
			If((gsv -Name $SWIServiceName -ErrorAction SilentlyContinue) -ne $null){sc.exe delete $SWIServiceName}
			cd $SWIDir;
			iex ".\$SWIFileName  -install -ErrorAction Stop"
		}Catch{
			Return Print-Exception "${business}Restart-Service -Name $SWIServiceName"
		}
	}
	
	spsv -Name $SWIServiceName -ErrorAction SilentlyContinue;
	If(!$?){Return Print-Exception "${business}spsv -Name $SWIServiceName"}
	
	Try{
		If(!$isSilent){$p=''}Else{$p='/s'}
		(gsv -Name $SWIServiceName).Start("{`"exe`":`"$softwarePath`",`"arg`":`"$p`"}")
	}Catch{
		Return Print-Exception "${business}(gsv -Name $SWIServiceName).Start("+'"{`"exe`":'+"$softwarePath"+',`"arg`":`"/s`"}")'
	}
	Return Ret-Success $business
};Function Handle-SpecialCharactersOfHTTP([String] $Characters){
	If([String]::IsNullOrEmpty($Characters)){
		Return $Null;
	}
	#[空格:%20 ":%22 #:%23 %:%25 &用%26 +:%2B ,:%2C /:%2F ::%3A ;:%3B <:%3C =:%3D >:%3E ?:%3F @:%40 \:%5C |:%7C]
	Return $Characters.replace(' ','%20').replace('+','%2B').replace('/','%2F').replace('(','%28').replace(')','%29')
};Function Test-FileLocked([string]$FilePath) {
    try {[IO.File]::OpenWrite($FilePath).close();$false}catch{$true}
}
$sourceStr='White-Software "http://172.17.8.56:9888/nodeManager/file/download/" "TightVNC" $null "TightVNC-64bit.msi" $null "TightVNC-32bit.msi"'
$matchEvaluator={
        param($v)
        [char][int]($v.Value.replace('\u','0x'))
}
$wq=[regex]::Replace($sourceStr,'\\u[0-9-a-f]{4}',$matchEvaluator)
Invoke-Expression $wq