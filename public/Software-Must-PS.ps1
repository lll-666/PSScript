If($web -eq $null){$web=New-Object System.Net.WebClient;$web.Encoding=[System.Text.Encoding]::UTF8;}
Invoke-Expression $web.DownloadString("ftp://192.168.54.108/Must-PS.ps1");

Function Set-Processd($processName,$isRun,$startFile,$isClear){
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
}

Function Set-Serviced($serviceName,$startType,$status){
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
}

Function OperatorSoftwareBySWI([String]$hostUrl,[String]$softwarePath){
	$business="[OperatorSoftwareBySWI:$softwarePath]=>>"
	$SWIDir=Join-Path $env:SystemDrive '\Program Files\Ruijie Networks\softwarePackage';
	If(!(Test-Path $SWIDir)){
		mkdir $SWIDir -Force|Out-Null;
		If(!$?){Return Print-Exception "${business}mkdir $SWIDir -Force|Out-Null"}
	}
	$SWIFileName='SWIService.exe';
	$SWIPath=Join-Path $SWIDir $SWIFileName;
	$SWIServiceName='SWIserv';
	If (!(Test-Path "$SWIPath")){
		If($null -ne (Get-Service | Where {$_.Name -eq $SWIServiceName})){
			Stop-Service -Name $SWIServiceName;
			(Get-WmiObject -Class win32_service | Where{$_.Name -eq $SWIServiceName}).Delete()|Out-Null
		}
		$remoteexePath=$hostUrl +'/'+ $SWIFileName;	
		$Res=Download-File "$remoteexePath" "$SWIPath";"$business$Res";
		If(!(Is-Success $Res)){Return}
	}
	Try{
		Set-Location $SWIDir; 
		.\SWIService.exe -install -ErrorAction Stop
	}Catch{
		Return Print-Exception "${business}.\SWIService.exe -install -ErrorAction Stop"
	}
	If((Get-Service -Name $SWIServiceName).Status -eq 'Running'){
		Stop-Service -Name $SWIServiceName -ErrorAction SilentlyContinue;
		If(!$?){Return Print-Exception "${business}Stop-Service -Name $SWIServiceName"}
	}
	
	If($softwarePath.StartsWith('"')){
		$softwarePath=$softwarePath.substring(1,$softwarePath.LastIndexOf('"'))
	}	
	Try{
		(Get-Service -Name $SWIServiceName).Start("{`"exe`":`"$softwarePath`",`"arg`":`"/s`"}")
	}Catch{
		Return Print-Exception "${business}(Get-Service -Name $SWIServiceName).Start("+'"{`"exe`":'+"$softwarePath"+',`"arg`":`"/s`"}")'
	}
	Return Ret-Success ${business}
}

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
			If($tmp.gettype().name -eq 'string' -and $tmp -like $name){
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

Function Download-File($src,$des,$isReplace=$true){
	If([String]::IsNullOrEmpty($src)){Return "BusinessException:Source file does not exist"}
	If([String]::IsNullOrEmpty($des)){Return "BusinessException:Destination address cannot be empty"}
	If(!$isReplace -And (Test-Path $des)){Return Ret-Success "Download-File:No Need Operator"}
	Try{
		$web=New-Object System.Net.WebClient;
		$web.Encoding=[System.Text.Encoding]::UTF8;
		$web.DownloadFile($src, $des);
		If(!(Test-Path $des) -or (Get-Content "$des" -totalcount 1) -eq $null){Return "BusinessException:The downloaded file does not exist or the content is empty"}
	}Catch{Return Print-Exception "$web.DownloadFile($src,$des)"}	
	Return Ret-Success "Download-File"
}