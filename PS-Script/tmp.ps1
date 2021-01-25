Function White-Software{
	param([String] $hostUrl,
		[String] $softwareName,
		[String] $softwareVersion,
		[String] $fileName64,
		[String] $fileName32,
		[bool] $isRun =$False,
		[String] $processName,
		[String] $serviceName
	);
	$business="[Install $softwareName]=>>";
	If([String]::isNullOrEmpty($softwareName)){Return "BusinessException:softwareName can not empty"}
	If((Get-SoftwareInfoByNameVersion $softwareName $softwareVersion) -ne $null){
		If(!$isRun){Return Ret-Success $business}
		If([String]::isNullOrEmpty($serviceName) -and [String]::isNullOrEmpty($processName)){
			Return "BusinessException:The software needs to be opened. The process name and service name cannot both be empty"
		}
		If(![String]::isNullOrEmpty($serviceName)){
			$Res = Set-Serviced $serviceName 'Automatic' 'Running';"$business$Res";
			If(Is-Success $Res){Return}
		}
		If(![String]::isNullOrEmpty($processName)){
			$Res = Set-Processd $processName $true $null;"$business$Res";
			If(Is-Success $Res){Return}
		}
	}ElseIf($softwareName -like '*guard*'){
		$processName='WINRDLV3'
		$Res = Set-Processd $processName $true "C:\WINDOWS\system32\winrdlv3.exe";"$business$Res";
		If(Is-Success $Res){Return}
	}

	If([String]::isNullOrEmpty($hostUrl)){Return "BusinessException:hostUrl can not empty"}
	If([String]::isNullOrEmpty($fileName64) -and [String]::isNullOrEmpty($fileName32)){Return "BusinessException:install package can not empty"}

	$downloadPath = Join-Path $env:SystemDrive '/Program Files/Ruijie Networks/softwarePackage/';
	If(!(Test-Path $downloadPath)){mkdir $downloadPath -Force|Out-Null}

	If([IntPtr]::Size -eq 8 -and ![String]::isNullOrEmpty($fileName64)){
		$bit='bit64';
		$fileName=$fileName64;
	}Else{
		$bit='bit32';
		$fileName=$fileName32
	}

	$softwarePath = Join-Path $downloadPath $fileName;
	If(!(Test-Path "$softwarePath") -or (Get-Content "$softwarePath" -TotalCount 1) -eq $null){
		$tmp=Handle-SpecialCharactersOfHTTP "?fileName=$fileName&dir=win/$bit";
		$remoteSoftwarePath=$hostUrl+'/temp'+$tmp;
		$Res=Download-File "$remoteSoftwarePath" "$softwarePath";"$business$Res";
		If(!(Is-Success $Res)){Return}
	}
	$Suffix=(Get-ChildItem -Path $softwarePath).Extension.substring(1);
	If('msi' -eq $Suffix){
		$os=Get-WmiObject -Class Win32_OperatingSystem | Select -ExpandProperty Caption
		If($os -Like '*Windows 7*' -Or $os -Like '*Windows 8*'){
			Invoke-Expression "& cmd /c `'msiexec.exe /i `"$softwarePath`"`' /qn ADVANCED_OPTIONS=1 CHANNEL=100"
		}Else{
			Invoke-Expression "Msiexec /i `"$softwarePath`" /norestart /qn" -ErrorAction SilentlyContinue;
			If(!$?){Return Print-Exception "Msiexec /i `"$softwarePath`" /norestart /qn"}
		}
	}else{
		$Res=OperatorSoftwareBySWI $hostUrl $softwarePath;"$business$Res";
		If(!(Is-Success $Res)){Return}
	}
	
	If((Get-SoftwareInfoByNameVersion $softwareName $softwareVersion) -eq $null){Return "BusinessException:Installation of the software has not been successful"}
	If($isRun){
		If(![String]::isNullOrEmpty($serviceName)){
			$Res = Set-Serviced $serviceName 'Automatic' 'Running';"$business$Res";
			If(!(Is-Success $Res)){Return}
		}
		If(![String]::isNullOrEmpty($processName)){
			$Res = Set-Processd $processName $true $startFileDir;"$business$Res";
			If(!(Is-Success $Res)){Return}
		}
	}
	Return Ret-Success $business
};Function Ret-Success([String] $business){
	Return "$business%%SMP:success"
};Function Is-Success($Ret){
	If($Ret -ne $null -And ($Ret|Select -Last 1).EndsWith('%%SMP:success')){Return $True}
	Return $False
};Function Print-Exception([String]$command){
	Return "execute Command [$command] Exception,The Exception is $($error[0])"
};Function Download-File([String]$src,[String]$des,[bool]$isReplace=$true){
	If([String]::IsNullOrEmpty($src)){Return "BusinessException:Source file does not exist"}
	If([String]::IsNullOrEmpty($des)){Return "BusinessException:Destination address cannot be empty"}
	If(!$isReplace -And (Test-Path $des)){Return Ret-Success "Download-File:No Need Operator"}
	Try{
		$web=New-Object System.Net.WebClient;
		$web.Encoding=[System.Text.Encoding]::UTF8;
		$web.DownloadFile("$src", "$des");
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
};Function Set-Serviced($serviceName,$startType,$status){
	$business="[Set-Serviced $serviceName]=>>"
	$service=Get-Service $serviceName -ErrorAction SilentlyContinue;
	If(!$?){Return Print-Exception "${business}Get-Service $serviceName"}
	if($service.status -ne $status){
		Set-Service $serviceName -StartupType Automatic -Status $status -ErrorAction SilentlyContinue;
		If(!$?){Print-Exception "Set-Service $serviceName -Status $status";}
		Sleep 1
	}
	#StartupType:[Boot|System|Automatic|Manual|Disabled],Status:[Running|Stopped|Paused]
	if($service.StartupType -ne $startType){
		Set-Service $serviceName -StartupType $startType -ErrorAction SilentlyContinue;
		If(!$?){Return Print-Exception "${business}Set-Service $serviceName -StartupType $startType"}
	}	
	Return Ret-Success $business
};Function Set-Processd([String]$processName,[String]$isRun,[String]$startFile,[String]$isClear){
	$business="[Set-Processd $processName]=>>"
	If([String]::isNullOrEmpty($processName)){
		Return "${business}BusinessException:processName can not empty"
	}
	
	$pro=Get-Process $processName -ErrorAction SilentlyContinue;
	If($isRun){
		If($pro -ne $null){
			Return '${business}No Need Operator%%SMP:success'
		}
		If([String]::isNullOrEmpty($startFile)){
			Return "${business}BusinessException:To start a process, The process startFile cannot be empty";	
		}
		
		If(!(Test-Path $startFile)){
			Return "${business}BusinessException:[$startFile] does not exist,cannot start process"
		}
		
		Start-Process $startFile -ErrorAction SilentlyContinue;
		If(!$?){Return Print-Exception "${business}Start-Process $startFile"}
		
		Return Ret-Success $business
	}Else{
		If($pro -eq $null){
			If($isClear){
				If([String]::isNullOrEmpty($startFile)){
					Return "${business}BusinessException:To clean up a process, The process startFile cannot be empty";	
				}
				Remove-Item -Force $startFile -ErrorAction SilentlyContinue;
				If(!$?){Return Print-Exception "${business}Remove-Item -Force $startFile"}
			}
			Return '${business}No Need Operator%%SMP:success'
		}
		
		$pro|Foreach{
			Stop-Process $_.Id -Force -ErrorAction SilentlyContinue;
			If(!$?){Print-Exception "Stop-Process $_.Id -Force"}
		}
		Sleep 1;
		
		$pro=Get-Process $processName -ErrorAction SilentlyContinue;	
		If($pro -ne $null){
			Return "${business}BusinessException:Failed to terminate process"
		}
		
		If($isClear){
			If([String]::isNullOrEmpty($startFile)){
				Return "${business}BusinessException:To start a process, The process startFile cannot be empty";	
			}
			
			If(!(Test-Path $startFile)){
				Return "${business}BusinessException:[$startFile] does not exist,cannot start process"
			}
			
			Remove-Item -Force $startFile -ErrorAction SilentlyContinue;
			If(!$?){Return Print-Exception "Remove-Item -Force $startFile"}
		}
		Return ${business}
	}
};Function OperatorSoftwareBySWI([String]$hostUrl,[String]$softwarePath,$isSilent=$True){
	$business="[OperatorSoftwareBySWI:$softwarePath]=>>"
	If([String]::IsNullOrEmpty("$softwarePath")){
		Return "uninstall script not exist"
	}
	If(!$softwarePath.EndsWith(".exe")){
		Return "uninstall script format error[$softwarePath]"
	}
	If($softwarePath.StartsWith('"')){
		$softwarePath=$softwarePath.substring(1,$softwarePath.LastIndexOf('"'))
	}
	$SWIDir=Join-Path $env:SystemDrive '\Program Files\Ruijie Networks\softwarePackage';
	If(!(Test-Path $SWIDir)){
		mkdir $SWIDir -Force|Out-Null;
		If(!$?){Return Print-Exception "${business}mkdir $SWIDir -Force|Out-Null"}
	}
	$SWIFileName='SWIService.exe';
	$SWIPath=Join-Path $SWIDir $SWIFileName;
	$SWIServiceName='SWIserv';
	$SWI=Get-Service -Name "${SWIServiceName}*"
	If (!(Test-Path "$SWIPath")){
		$remoteexePath=$hostUrl +'/'+ $SWIFileName;	
		$Res=Download-File "$remoteexePath" "$SWIPath";"$business$Res";
		If(!(Is-Success $Res)){Return}
	}
	
	If($null -eq $SWI){
		Try{
			Set-Location $SWIDir; 
			.\SWIService.exe -install -ErrorAction Stop
		}Catch{
			Return Print-Exception "${business}.\SWIService.exe -install -ErrorAction Stop"
		}
	}else{
		If($SWI.Status -eq 'Running'){
			Stop-Service -Name $SWIServiceName -ErrorAction SilentlyContinue;
			If(!$?){Return Print-Exception "${business}Stop-Service -Name $SWIServiceName"}
		}
	}
	Try{
		$p='/s'
		If(!$isSilent){$p=''}
		(Get-Service -Name $SWIServiceName).Start("{`"exe`":`"$softwarePath`",`"arg`":`"$p`"}")
	}Catch{
		Return Print-Exception "${business}(Get-Service -Name $SWIServiceName).Start("+'"{`"exe`":'+"$softwarePath"+',`"arg`":`"/s`"}")'
	}
	Return Ret-Success ${business}
};Function Handle-SpecialCharactersOfHTTP([String] $Characters){
	If([String]::IsNullOrEmpty($Characters)){
		Return $Null;
	}
	#[空格:%20 ":%22 #:%23 %:%25 &用%26 +:%2B ,:%2C /:%2F ::%3A ;:%3B <:%3C =:%3D >:%3E ?:%3F @:%40 \:%5C |:%7C]
	Return $Characters.replace(' ','%20').replace('+','%2B').replace('/','%2F')
}
$sourceStr='White-Software "http://172.17.8.218:9888//nodeManager/file/download/" "\u004e\u006f\u0074\u0065\u0070\u0061\u0064\u002b\u002b\u0020\u0028\u0033\u0032\u002d\u0062\u0069\u0074\u0020\u0078\u0038\u0036\u0029" "7.8.4" "\u004e\u006f\u0074\u0065\u0070\u0061\u0064\u002b\u002b\u0020\u0028\u0033\u0032\u002d\u0062\u0069\u0074\u0020\u0078\u0038\u0036\u0029\u005f\u0037\u002e\u0038\u002e\u0034\u005f\u0075\u0072\u006c\u002e\u0070\u006e\u0067" $null $false $null'
$matchEvaluator={
        param($v)
        [char][int]($v.Value.replace('\u','0x'))
}
$wq=[regex]::Replace($sourceStr,'\\u[0-9-a-f]{4}',$matchEvaluator)
Invoke-Expression $wq