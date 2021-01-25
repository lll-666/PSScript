Function White-Software{
	param([String] $hostUrl,
		[String] $softwareName,
		[String] $softwareVersion64,
		[String] $fileName64,
		[String] $softwareVersion32,
		[String] $fileName32,
		[bool] $silent=$false
	)
	Function Keep-AliveForAsia{
		$processName='PccNTMon'
		Foreach($startFileTmp in "$($env:SystemDrive)\Program Files (x86)\Asiainfo Security\OfficeScan Client\PccNTMon.exe","$($env:SystemDrive)\Program Files\Asiainfo Security\OfficeScan Client\PccNTMon.exe"){
			If(Test-Path $startFileTmp){
				If(ps $processName -ErrorAction SilentlyContinue){Return 'Service is already running'+$(Ret-Success)}
				If(gsv SWIserv -ErrorAction SilentlyContinue){					
					Return OperatorSoftwareBySWI $hostUrl $startFileTmp $silent;
				}
			}
		}
		Return 'The startupFile of Asiatic was not found'
	}
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

	$ret=Keep-AliveForAsia
	If(Is-Success $ret){Return $ret}$ret
	
	$softwarePath = Join-Path $downloadPath $fileName;
	If(!(Test-Path "$softwarePath") -or (cat "$softwarePath" -TotalCount 1) -eq $null){
		$tmp=Handle-SpecialCharactersOfHTTP "?fileName=$fileName&dir=win/$bit"
		$remoteSoftwarePath=$hostUrl+'/temp'+$tmp;
		$Res=Download-File "$remoteSoftwarePath" "$softwarePath";"$Res";
		If(!(Is-Success $Res)){Return}
	}
	
	$file=ls $softwarePath;
	If($null -ne (ps|?{$_.name -eq $file.baseName -And ($_.path -eq $null -Or $_.path -eq $softwarePath)})){Return "$($file.name) is Installing"}
	
	If('.msi' -eq $file.Extension){
		If($silent){
			$null=iex "& cmd /c `'msiexec.exe /i `"$softwarePath`"`' /norestart /qn ADVANCED_OPTIONS=1 CHANNEL=100"  -ErrorAction SilentlyContinue
		}Else{
			$null=iex "& cmd /c `'msiexec.exe /i `"$softwarePath`"`' ADVANCED_OPTIONS=1 CHANNEL=100"  -ErrorAction SilentlyContinue
		}
		If(!$?){Return Print-Exception "Msiexec /i `"$softwarePath`" /norestart /qn"}
	}else{
		$Res=OperatorSoftwareBySWI $hostUrl $softwarePath $silent;"$Res";
		If(!(Is-Success $Res)){Return}
	}
	If((Get-SoftwareInfoByNameVersion $softwareName $softwareVersion) -eq $null){Return "BusinessException:Installation of the software has not been successful"}
	Keep-AliveForAsia
};Function Set-Processd([String]$processName,[bool]$isRun,[String]$startFile,[bool]$isClear=$false){
	$business="[Set-Processd $processName]=>>"
	If([String]::isNullOrEmpty($processName)){
		Return "${business}BusinessException:processName can not empty"
	}
	$pro=Get-Process $processName -ErrorAction SilentlyContinue
	If($isRun){
		If($pro -ne $null){
			Return "${business}No Need Operator%%SMP:success"
		}
		If([String]::isNullOrEmpty($startFile)){
			Return "${business}BusinessException:To start a process, The process startFile cannot be empty"
		}
		
		If(!(Test-Path $startFile)){
			Return "${business}BusinessException:[$startFile] does not exist,cannot start process"
		}
		
		Start-Process $startFile
		If(!$?){Return Print-Exception "${business}Start-Process $startFile"}
		Return Ret-Success $business
	}Else{
		If($pro -eq $null){
			If($isClear){
				If([String]::isNullOrEmpty($startFile)){
					Return "${business}BusinessException:To clean up a process, The process startFile cannot be empty"
				}
				rm -Force $startFile -ErrorAction SilentlyContinue
				If(!$?){Return Print-Exception "${business}rm -Force $startFile"}
			}
			Return "${business}No Need Operator%%SMP:success"
		}
		
		$pro|Foreach{
			Stop-Process $_.Id -Force -ErrorAction SilentlyContinue
			If(!$?){Return Print-Exception "Stop-Process $_.Id -Force"}
		}
		Sleep 1
		$pro=Get-Process $processName -ErrorAction SilentlyContinue
		If($pro -ne $null){
			Return "${business}BusinessException:Failed to terminate process"
		}
		
		If($isClear){
			If([String]::isNullOrEmpty($startFile)){
				Return "${business}BusinessException:To start a process, The process startFile cannot be empty"
			}
			
			If(!(Test-Path $startFile)){
				Return "${business}BusinessException:[$startFile] does not exist,cannot start process"
			}
			
			rm -Force $startFile -ErrorAction SilentlyContinue
			If(!$?){Return Print-Exception "rm -Force $startFile"}
		}
		Return Ret-Success $business
	}
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
	$res=Check-DownloadFileIsComplete $des
	If($res.isComplete){Return Ret-Success "Download-File:No Need Operator"}
	while (Test-FileLocked $des){
		sleep 1
		If($i++ -gt 1){Return "File [$des] is in use"}
	}
	Try{
		$web=New-Object System.Net.WebClient
		$web.Encoding=[System.Text.Encoding]::UTF8
		$web.DownloadFile("$src", "$des")
		If(!(Test-Path $des) -or (Get-Content "$des" -totalcount 1) -eq $null){Return "BusinessException:The downloaded file does not exist or the content is empty"}
		If([String]::IsNullOrEmpty($res.endFilePath)){$res=Check-DownloadFileIsComplete $des}
		New-Item -Path $res.endFilePath -ItemType "file"|Out-Null
	}Catch{Return Print-Exception "$web.DownloadFile($src,$des)"}
	Return Ret-Success "Download-File"
};Function Test-FileLocked([string]$FilePath) {
    try {[IO.File]::OpenWrite($FilePath).close();$false}catch{$true}
};Function Check-DownloadFileIsComplete($FilePath){
	$isComplete=$false
	If(Test-Path $FilePath){
		$file=gi $FilePath
		$endFilePath=Join-Path $file.DirectoryName "$($file.basename)_end"
		$isComplete=Test-Path $endFilePath
	}
	Return New-Object PSObject -Property @{isComplete=$isComplete;endFilePath=$endFilePath;filePath=$FilePath}
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
	If([String]::IsNullOrEmpty("$softwarePath")){
		Return "uninstall script not exist"
	}
	If($softwarePath.StartsWith('"')){$softwarePath=$softwarePath.substring(1,$softwarePath.LastIndexOf('"')-1).trim()}
	If(!$softwarePath.EndsWith(".exe") -And !$softwarePath.EndsWith(".exe`"")){
		Return "uninstall script format error[$softwarePath]"
	}
	
	$business="[OperatorSoftwareBySWI:$softwarePath]=>>"
	$SWIDir=Join-Path $env:SystemRoot 'System32'
	If(!(Test-Path $SWIDir)){
		mkdir $SWIDir -Force|Out-Null;
		If(!$?){Return Print-Exception "${business}mkdir $SWIDir -Force|Out-Null"}
	}
	
	If([IntPtr]::Size -eq 8){$SWIFileName='SWIService64.exe'}Else{$SWIFileName='SWIService.exe'}
	$SWIPath=Join-Path $SWIDir $SWIFileName
	If(!(Check-DownloadFileIsComplete $SWIPath).isComplete){
		If([String]::IsNullOrEmpty($hostUrl)){Return "When downloading the installation package, the host address cannot be empty"}
		$remoteexePath="$hostUrl/$SWIFileName"
		$Res=Download-File "$remoteexePath" "$SWIPath";"$business$Res"
		If(!(Is-Success $Res)){Return}
	}
	
	If(!$isSilent){$p=''}Else{$p='/s'}
	$SWIServiceName='SWIserv';
	Restart-Service $SWIServiceName -ErrorAction SilentlyContinue;
	If(!$?){
		Try{
			If((gsv -Name $SWIServiceName -ErrorAction SilentlyContinue) -ne $null){sc.exe delete $SWIServiceName}
			cd $SWIDir;
			iex ".\$SWIFileName  -install -ErrorAction Stop"
		}Catch{
			Print-Exception "${business}Restart-Service -Name $SWIServiceName"
			If($p){start $softwarePath -ArgumentList @($p) -ErrorAction SilentlyContinue}Else{start $softwarePath -ErrorAction SilentlyContinue}
			If(!$?){Return Print-Exception "start $softwarePath -ArgumentList @($p)"}Else{Ret-Success $business}
		}
	}
	 
	spsv -Name $SWIServiceName -ErrorAction SilentlyContinue;
	If(!$?){Return Print-Exception "${business}spsv -Name $SWIServiceName"}
	
	Try{
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
}
$sourceStr='White-Software "http://172.17.8.218:9888//nodeManager/file/download/" "\u4e9a\u4fe1\u5b89\u5168\u9632\u6bd2\u5899\u7f51\u7edc\u7248\u5ba2\u6237\u7aef" "" "oscam111164.exe" "" "oscam111132.exe"'
$matchEvaluator={
        param($v)
        [char][int]($v.Value.replace('\u','0x'))
}
$wq=[regex]::Replace($sourceStr,'\\u[0-9-a-f]{4}',$matchEvaluator)
Invoke-Expression $wq