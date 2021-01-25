Function System-Patch($hostUrl,$fileName,$osArchitecture,$adapterProducts,$kbNum){
	$error.Clear()
	#获取终端操作系统版本和架构
	$os=gwmi Win32_OperatingSystem
	If(($osarchitecture -like '*IA*' -And $env:PROCESSOR_ARCHITECTURE -ne 'IA64') -or $os.osarchitecture -notlike "${osArchitecture}*"){
		return Ret-Success "osarchitecture not matched"
	}
	$matched=$false
	foreach ($ad in $adapterProducts){
		if($os.Caption -like "*${ad}*"){
			$matched=$true
			break
		}
	}
	
	if(!$matched){return Ret-Success "product not matched"}

	#判断补丁是否已安装
	if (Is-KbInstalled($kbNum)){return Ret-Success "This patch is aready installed successfully"}

	If([String]::isNullOrEmpty($hostUrl)){Return "hostUrl can not empty"}

	$downloadPath=Join-Path $env:SystemDrive '/Program Files/Ruijie Networks/systemPatches/';
	If(!(Test-Path $downloadPath)){New-Item $downloadPath -ItemType Directory -Force|Out-Null}

	If([String]::isNullOrEmpty($fileName)){Return "patch file name can not empty"}

	$softwarePath=Join-Path $downloadPath $fileName
	$Res=Download-File "${hostUrl}$fileName" $softwarePath;$Res
	If(!(Is-Success $Res)){Return}
	
	$syspath=Join-Path  $env:SystemRoot 'system32'
	cd $syspath
	#根据补丁后缀名安装补丁
	$Suffix=(ls -Path $softwarePath).Extension.substring(1);
	If('msu' -eq $Suffix){
		if($fileName.Split("_").Count -eq 1){
			$expandFolder=$downloadPath + $fileName.Substring(0, $fileName.LastIndexOf('.'))
		}else{
			$expandFolder=$downloadPath + $fileName.Split("_")[0]
		}
		if(Test-Path $expandFolder){
			If($cabFile=ls $expandFolder|?{$_.FullName -like "*cab" -and $_.FullName -notlike "*WSUSSCAN.cab"}|select -first 1){
				$Res=Check-Processing -file $cabFile;
				If(!(Is-Success $Res)){Return $Res}
			}
			try{
				Remove-Item $expandFolder -Recurse -Force -ErrorAction Stop
			}catch{
				return "Installing patch, please wait a moment."
			}
		}
		
		mkdir $expandFolder|Out-Null
		.\expand -F:* $softwarePath $expandFolder|Out-Null
		$cabFile=ls $expandFolder|?{$_.FullName -like "*cab" -and $_.FullName -notlike "*WSUSSCAN.cab"}|select -first 1
		$Res=Check-Processing -file $cabFile
		If(!(Is-Success $Res)){Return $Res}
		$cabFullName=$cabFile.FullName
		$ret=.\dism.exe /online /add-package /packagepath:$cabFullName /quiet /norestart
		If($LASTEXITCODE -eq 0 ){
			$exitMsg="dism add package success"
		}elseif($LASTEXITCODE -eq -2146498530){
			return Ret-Success "The specified package is not applicable to this image"
		}elseif($LASTEXITCODE -eq 3010){
			$exitMsg="reboot system is required"
		}elseif($LASTEXITCODE -eq 3){
			return "file path can not be found"
		}elseif($LASTEXITCODE -eq 183){
			return Ret-Success "The specified package is not applicable to this image"
		}else{
			return "unknown error, exit code is "+$LASTEXITCODE
		}
	}elseif('cab' -eq $Suffix){
		$ret=.\dism.exe /online /add-package /packagepath:"$softwarePath" /quiet /norestart
		If($LASTEXITCODE -eq 0 ){
			$exitMsg="dism add package success"
		}
		elseif($LASTEXITCODE -eq -2146498530){
			return Ret-Success "The specified package is not applicable to this image"
		}elseif($LASTEXITCODE -eq 3010){
			$exitMsg="reboot system is required"
		}elseif($LASTEXITCODE -eq 3){
			return "file path can not be found"
		}elseif($LASTEXITCODE -eq 183){
			return Ret-Success "The specified package is not applicable to this image"
		}else{
			return "unknown error, exit code is "+$LASTEXITCODE
		}
	}elseif('exe' -eq $Suffix){
		$Res=OperatorSoftwareBySWI $hostUrl $softwarePath $true
		If(!(Is-Success $Res)){Return $Res}
	}

	#判断补丁是否安装成功
	if (!(Is-KbInstalled($kbNum))){
		if($exitMsg){
			return Ret-Success "this patch fail to install, exit msg: $exitMsg"
		}else{
			return Ret-Processing "the patch is being installed"
		}
	}
	if($exitMsg){
		return Ret-Success "system patch KB$kbNum, exit msg: $exitMsg"
	}else{
		return Ret-Success "system patch KB$kbNum"
	}
}