Function White-Software{
	param([String] $hostUrl,
		[String] $softwareName,
		[String] $softwareVersion64,
		[String] $fileName64,
		[String] $softwareVersion32,
		[String] $fileName32
	);
	If([String]::isNullOrEmpty($softwareName)){Return "BusinessException:softwareName can not empty"}
	If([String]::isNullOrEmpty($hostUrl)){Return "BusinessException:hostUrl can not empty"}
	If([String]::isNullOrEmpty($fileName64) -and [String]::isNullOrEmpty($fileName32)){Return "BusinessException:install package can not empty"}

	$downloadPath = Join-Path $env:SystemDrive '/Program Files/Ruijie Networks/softwarePackage/';
	If(!(Test-Path $downloadPath)){mkdir $downloadPath -Force|Out-Null}
	If([IntPtr]::Size -eq 8 -and ![String]::isNullOrEmpty($fileName64)){
		$softwareVersion=$softwareVersion64;
		$bit='bit64';
		$fileName=$fileName64;
	}Else{
		$softwareVersion=$softwareVersion32;
		$bit='bit32';
		$fileName=$fileName32
	}
	If((Get-SoftwareInfoByNameVersion $softwareName $softwareVersion) -ne $null){Return Ret-Success "${softwareName} has been installed"}
	$softwarePath = Join-Path $downloadPath $fileName;
	If(!(Test-Path "$softwarePath") -or (Get-Content "$softwarePath" -TotalCount 1) -eq $null){
		$tmp=Handle-SpecialCharactersOfHTTP "?fileName=$fileName&dir=win/$bit";
		$remoteSoftwarePath=$hostUrl+'/temp'+$tmp;
		$Res=Download-File "$remoteSoftwarePath" "$softwarePath";"$Res";
		If(!(Is-Success $Res)){Return}
	}
	
	$file=ls $softwarePath;
	$Suffix=$file.Extension.substring(1);
	If($null -ne (Get-Process|?{$_.name -eq $file.baseName -And ($_.path -eq $null -Or $_.path -eq $softwarePath)})){Return "$($file.name) is Installing"}
	
	If('msi' -eq $Suffix){
		$os=Get-WmiObject -Class Win32_OperatingSystem | Select -ExpandProperty Caption
		If($os -Like '*Windows 7*' -Or $os -Like '*Windows 8*'){
			iex "& cmd /c `'msiexec.exe /i `"$softwarePath`"`' /qn ADVANCED_OPTIONS=1 CHANNEL=100"
		}Else{
			iex "Msiexec /i `"$softwarePath`" /norestart /qn" -ErrorAction SilentlyContinue;
			If(!$?){Return Print-Exception "Msiexec /i `"$softwarePath`" /norestart /qn"}
		}
	}else{
		$Res=OperatorSoftwareBySWI $hostUrl $softwarePath $true;"$Res";
		If(!(Is-Success $Res)){Return}
	}
	If((Get-SoftwareInfoByNameVersion $softwareName $softwareVersion) -eq $null){Return "BusinessException:Installation of the software has not been successful"}
	Return Ret-Success 
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
};Function Test-FileLocked([string]$FilePath) {
    try {[IO.File]::OpenWrite($FilePath).close();$false}catch{$true}
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
	$SWI=gsv $SWIServiceName -ErrorAction SilentlyContinue
	If($null -eq $SWI){
		Try{
			cd $SWIDir;
			iex ".\$SWIFileName  -install -ErrorAction Stop"
		}Catch{
			Return Print-Exception "${business}.\SWIService.exe -install -ErrorAction Stop"
		}
	}else{
		If($SWI.Status -eq 'Running'){
			spsv -Name $SWIServiceName -ErrorAction SilentlyContinue;
			If(!$?){Return Print-Exception "${business}spsv -Name $SWIServiceName"}
		}
	}
	Try{
		$p='/s'
		If(!$isSilent){$p=''}
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

Function Unified-Return([Object[]]$msgs,[Parameter(Mandatory = $true)][String]$business){
	If($msgs -eq $Null -Or $msgs.count -eq 0){
		$isSuccess='false';
		$msg='No message returned';
	}Else{
		If(($msgs[-1]).EndsWith('%%SMP:success')){
			$isSuccess='true';
		}Else{
			$isSuccess='false';
		}
		$msg=($msgs -Join ';	').replace('\','/')
	}
	Return "{`"isSuccess`":`"$isSuccess`",`"msg`":`"$msg`",`"business`":`"$business`"}";
}

Function UnicodeToChinese([String]$sourceStr){
	[regex]::Replace($sourceStr,'\\u[0-9-a-f]{4}',{param($v);[char][int]($v.Value.replace('\u','0x'))})
}

Function Install-SDSotware([String] $hostUrl,$softwareName1,$softwareVersion1,$fileName1,$softwareName2,$softwareVersion2){
	If((Get-SoftwareInfoByNameVersion $softwareName2 $softwareVersion2) -ne $null){
		Unified-Return (Ret-Success "${softwareName2} has been installed") 'Install-SDSotware'
	}Else{
		Unified-Return (White-Software -hostUrl $hostUrl -softwareName $softwareName1 -softwareVersion32 $softwareVersion1 -fileName32 $fileName1) 'Install-SDSotware'
	}
}
$sourceStr='Install-SDSotware -hostUrl "http://172.17.8.218:9888/nodeManager/file/download/" -softwareName1 "\u0033\u0036\u0030\u6740\u6bd2" -softwareVersion1 "5.0.0.8170" -fileName1 "360sd_x64_std_5.0.0.8170D.exe"  -softwareName2 "\u91d1\u5c71\u6bd2\u9738" -softwareVersion2 "2020.11.2.4"'
iex (UnicodeToChinese $sourceStr)
