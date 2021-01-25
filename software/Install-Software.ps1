$hostUrl='~hostUrl~';
$fileName64='~fileName64~';
$fileName32='~fileName32~';
$softwareName='~softwareName~';
$serviceName='~serviceName~';
$processName='~processName~';
$startFileDir='~~startFileDir~~'
$isRun='~isRun~';

If("$hostUrl" -like '~hostUrl*'){$hostUrl=''}
If("$softwareName" -like '~softwareName*'){$softwareName=''}
If("$fileName64" -like '~fileName64*'){$fileName64=''}
If("$fileName32" -like '~fileName32*'){$fileName32=''}
If("$serviceName" -like '~serviceName*'){$serviceName=''}
If("$processName" -like '~processName*'){$processName=''}
If("$isRun" -like '~isRun*'){$isRun=''}
If("$startFileDir" -like '~~startFileDir*'){$startFileDir=''}

Function Print-Exception($command){Return "execute Command [$command] Exception,The Exception is $($error[0])"}

If($isRun -eq $true){
	If([String]::isNullOrEmpty($serviceName) -and [String]::isNullOrEmpty($processName)){
		Return "BusinessException:The software needs to be opened. The process name and service name cannot both be empty"
	}
	
	If(![String]::isNullOrEmpty($serviceName)){
		$service=Get-Service $serviceName -ErrorAction SilentlyContinue;
		If(!$?){
			Print-Exception "Get-Service $serviceName"
		}Else{
			If($service.status -eq 'Running'){Return "0%%SMP:success"}
			
			Start-Service $serviceName -ErrorAction SilentlyContinue;
			If($?){Return "1%%SMP:success"}
			Print-Exception "Start-Service $serviceName"
		}
	}
	
	If(![String]::isNullOrEmpty($processName)){
		$process=Get-Process $processName -ErrorAction SilentlyContinue;
		If(!$?){
			Print-Exception "Get-Process $processName"
		}Else{
			If($process -ne $null){
				Return "2%%SMP:success"
			}
		}
		
		if(![String]::isNullOrEmpty($startFileDir)){
			if(!(Test-Path $startFileDir)){Return "BusinessException:[$startFileDir] does not exist"}
			
			$ProcessPath=$startFileDir+'\'+$processName+'.exe';
			If(Test-Path $ProcessPath){
				Start-Process $ProcessPath -ErrorAction SilentlyContinue;
				if($?){Return "3%%SMP:success"}
			}
		}
	}
}

If([String]::isNullOrEmpty($softwareName)){
	Return "BusinessException:softwareName can not empty"	
}

Function Get-SoftwareInfo([String] $col,[String] $val){
	$Key='Software\Microsoft\Windows\CurrentVersion\Uninstall','SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall';
	If([IntPtr]::Size -eq 8){$Key+='SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'}
	Foreach($_ In $Key){
	  $Hive='LocalMachine';
	  If('Software\Microsoft\Windows\CurrentVersion\Uninstall' -ceq $_){$Hive='CurrentUser'}
	  $RegHive=[Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($Hive,$env:COMPUTERNAME);
	  $RegKey=$RegHive.OpenSubKey($_);
	  If([string]::IsNullOrEmpty($RegKey)){Return}
	  $arrs=$RegKey.GetSubKeyNames();
	  Foreach($_ In $arrs){
		$SubKey=$RegKey.OpenSubKey($_);
		$tmp=$subkey.GetValue($col);
		If(![string]::IsNullOrEmpty($tmp)){
			If($tmp.gettype().name -eq 'string' -And $tmp -Like $val){
				$retVal=''|Select 'DisplayName','DisplayVersion','UninstallString','InstallLocation','RegPath','InstallDate','InstallSource';
				$retVal.DisplayName=$subkey.GetValue('DisplayName');
				$retVal.DisplayVersion=$subkey.GetValue('DisplayVersion');
				$retVal.UninstallString=$subkey.GetValue('UninstallString');
				$retVal.InstallLocation=$subkey.GetValue('InstallLocation');
				$retVal.RegPath=$subkey.GetValue('RegPath');
				$retVal.InstallDate=$subkey.GetValue('InstallDate');
				$retVal.InstallSource=$subkey.GetValue('InstallSource');
				Return $retVal
			}
		}
		$SubKey.Close()
	  };
	  $RegHive.Close()
	};
}

$retVal=Get-SoftwareInfo 'DisplayName' $softwareName

If($retVal -ne $null -And !$isRun){
	Return "4%%SMP:success"
}

If([String]::isNullOrEmpty($hostUrl)){
	Return "BusinessException:hostUrl can not empty"
}

$downloadPath = Join-Path $env:SystemDrive '/Program Files/Ruijie Networks/softwarePackage/';
If(!(Test-Path $downloadPath)){New-Item $downloadPath -ItemType Directory -Force|Out-Null}
Set-Location $downloadPath

If([String]::isNullOrEmpty($fileName64) -And [String]::isNullOrEmpty($fileName32)){
	Return "BusinessException:install package can not empty"
}

If([IntPtr]::Size -eq 8){
	$bit='bit64';
	$fileName=$fileName64;
	If([String]::isNullOrEmpty($fileName64)){
		$fileName=$fileName32;
		$bit='bit32'
	}
}Else{
	$bit='bit32';
	$fileName=$fileName32
}

If([String]::isNullOrEmpty($fileName)){
	Return "BusinessException:no installation package available"
}

$softwarePath = Join-Path $downloadPath $fileName;
If(!(Test-Path "$softwarePath") -or (Get-Content "$softwarePath").length -eq 0) {
	$remoteSoftwarePath=$hostUrl+"/temp?fileName=$fileName&dir=$bit";
	try{
		(New-Object System.Net.WebClient).DownloadFile("$remoteSoftwarePath" , "$softwarePath");
		If((Get-Content "$softwarePath").length -eq 0){
			Return "BusinessException:no installation package available"
		}
	}Catch{
		Return Print-Exception ('(New-Object System.Net.WebClient).DownloadFile('+"`"$remoteSoftwarePath`",`"$softwarePath`")")
	}		
}

$Suffix=(Get-ChildItem -Path $softwarePath).Extension.substring(1);
If('msi' -ne $Suffix){
	$SWIFileName='SWIService.exe';
	$SWIServicePath=Join-Path $downloadPath $SWIFileName;
	$SWIServiceName='SWIserv';
	If (!(Test-Path `"$SWIServicePath`")){
		If($null -ne (Get-Service | Where-Object {$_.Name -eq $SWIServiceName})){
			Stop-Service -Name $SWIServiceName;
			(Get-WmiObject -Class win32_service | Where-Object {$_.Name -eq $SWIServiceName}).Delete()|Out-Null
		}
		$remoteSwiServicePath=$hostUrl +'/'+ $SWIFileName;
		try{
			(New-Object System.Net.WebClient).DownloadFile("$remoteSwiServicePath","$SWIServicePath");
		}Catch{
			Return Print-Exception ('(New-Object System.Net.WebClient).DownloadFile('+"`"$remoteSwiServicePath`",`"$SWIServicePath`")")
		}
		try{
			.\SWIService.exe -install -ErrorAction Stop;
		}Catch{
			Return Print-Exception '.\SWIService.exe -install -ErrorAction Stop'
		}
	}

	If((Get-Service -Name $SWIServiceName).Status -eq 'Running'){
		Stop-Service -Name $SWIServiceName -ErrorAction SilentlyContinue;
		If(!$?){
			Return Print-Exception 'Stop-Service -Name $SWIServiceName -ErrorAction SilentlyContinue'
		}
	}
}

try{
	If('msi' -ne $Suffix){
		(Get-Service -Name $SWIServiceName).Start("{`"$Suffix`":`"$softwarePath`",`"arg`":`"/s`"}")
		Start-Sleep -Seconds 5
	}Else{
		msiexec -i $softwarePath -qn REBOOT=SUPPRESS
		Start-Sleep -Seconds 3
	}
}Catch{
	Return Print-Exception "Install [$softwarePath]"
}

If($isRun -eq $true){
	If(![String]::isNullOrEmpty($serviceName)){
		$service=Get-Service $serviceName -ErrorAction SilentlyContinue;
		If(!$?){Return Print-Exception "Get-Service $serviceName"}
		
		If($service.status -eq 'Running'){
			Return "6%%SMP:success"
		}Else{
			Start-Service $serviceName -ErrorAction SilentlyContinue;
			If($?){Return "7%%SMP:success"}
			Print-Exception "Start-Service $serviceName";
			If([String]::isNullOrEmpty($processName)){Return}
		}
	}
	
	If(![String]::isNullOrEmpty($processName)){
		$process=Get-Process $processName -ErrorAction SilentlyContinue;
		If(!$?){Print-Exception "Get-Process $processName";}
		If($process -ne $null){Return "8%%SMP:success"}
		If(Test-Path $ProcessPath){
			Start-Process $ProcessPath -ErrorAction SilentlyContinue;
			if($?){Return "9%%SMP:success"}
		}
	}
}
Return "10%%SMP:success"