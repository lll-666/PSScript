Function White-Software{
	param([String] $hostUrl,
		[String] $softwareName,
		[String] $softwareVersion64,
		[String] $fileName64,
		[String] $softwareVersion32,
		[String] $fileName32,
		[bool] $silent=$false
	)
	Function Check-IPGuard{
		If((ps winrdlv3 -ErrorAction SilentlyContinue) -eq $null){Return $false}
		If(!(netstat -an|findstr 8235|findstr LISTENING)){Return $false}
		If(!($SV=gwmi win32_service |?{$_.name -eq '.Winhlpsvr' -And $_.status -eq 'OK'}|select pathname)){Return $false}
		Test-Path (($SV.pathname).Replace('"',''))
	}
	If([String]::isNullOrEmpty($softwareName)){Return "BusinessException:softwareName can not empty"}
	If([String]::isNullOrEmpty($hostUrl)){Return "BusinessException:hostUrl can not empty"}
	If([String]::isNullOrEmpty($fileName64) -and [String]::isNullOrEmpty($fileName32)){Return "BusinessException:install package can not empty"}
	
	If($softwareName -like '*guard*' -And (Check-IPGuard)){Return Ret-Success "${softwareName} has been installed"}
	
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

	If((Get-SoftwareInfoByNameVersion $softwareName $softwareVersion) -ne $null){Return Ret-Success "${softwareName} has been installed"}
	$softwarePath = Join-Path $downloadPath $fileName;
	If(!(Test-Path "$softwarePath") -or (cat "$softwarePath" -TotalCount 1) -eq $null){
		$tmp=Handle-SpecialCharactersOfHTTP "?fileName=$fileName&dir=win/$bit";
		$remoteSoftwarePath=$hostUrl+'/temp'+$tmp;
		$Res=Download-File "$remoteSoftwarePath" "$softwarePath";$Res;
		If(!(Is-Success $Res)){Return}
	}
	$file=ls $softwarePath
	If('.msi' -eq $file.Extension){
		$Res=OperatorSoftwareByMSI $softwarePath 'install' $silent
	}else{
		$Res=OperatorSoftwareBySWI $hostUrl $softwarePath $silent
	}
	If(!(Is-Success $Res)){Return $Res}
	If((Get-SoftwareInfoByNameVersion $softwareName $softwareVersion) -eq $null){Return Ret-Processing "the software has not been installed successfully"}
	Return Ret-Success 
}