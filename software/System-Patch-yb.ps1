Function System-Patch($hostUrl,$fileName,$osArchitecture,$adapterProducts,$kbNum){
    $error.Clear()
    #获取终端操作系统版本和架构
    $product = (Get-WmiObject -Class Win32_OperatingSystem).Caption
    $matched = $false
    foreach ($ad in $adapterProducts){
        if($product -like "*"+$ad+"*"){
            $matched = $true
            break
        }
    }
    if(!$matched){
        return "product not matched %%SMP:success"
    }

    if(!((Get-WmiObject -Class Win32_OperatingSystem).osarchitecture -match (""+$osArchitecture+".*"))){
        return "osarchitecture not matched %%SMP:success"
    }

    #判断补丁是否已安装
    if (Is-KbInstalled($kbNum)){
        return "This patch is aready installed successfully %%SMP:success"
    }


    #下载补丁文件到终端
    $web=New-Object System.Net.WebClient;

    If([String]::isNullOrEmpty($hostUrl)){
	    Return "BusinessException:hostUrl can not empty"
    }

    $downloadPath = Join-Path $env:SystemDrive '/Program Files/Ruijie Networks/systemPatches/';
    If(!(Test-Path $downloadPath)){New-Item $downloadPath -ItemType Directory -Force|Out-Null}
    Set-Location $downloadPath

    If([String]::isNullOrEmpty($fileName)){
	    Return "BusinessException:patch file name can not empty"
    }

    $softwarePath = Join-Path $downloadPath $fileName;
    If(!(Test-Path "$softwarePath") -or (Get-Item "$softwarePath").length -eq 0) {
	    $remoteSoftwarePath=$hostUrl+"$fileName";
	    try{
		    $web.DownloadFile("$remoteSoftwarePath", "$softwarePath")
		    If((Get-Item "$softwarePath").length -eq 0){
			    Return "BusinessException:no installation package available"
		    }
	    }Catch{
		    Return Print-Exception ("$web.DownloadFile(`"$remoteSoftwarePath`",`"$softwarePath`")")
	    }
    }

    #根据补丁后缀名安装补丁
    $Suffix=(Get-ChildItem -Path $softwarePath).Extension.substring(1);
    If('msu' -eq $Suffix){
        if($fileName.Split("_").Count -eq 1){
            $expandFolder = $downloadPath + $fileName.Substring(0, $fileName.LastIndexOf('.'))
        }else{
            $expandFolder = $downloadPath + $fileName.Split("_")[0]
        }
        $stateFilePath=$expandFolder+'\KB'+$kbNum+'state.txt'
        if(Test-Path $expandFolder){
            if(Test-Path $stateFilePath){
                $state = Get-Content $stateFilePath
                if($state -eq "installing"){
                    return "Installing patch, please wait a moment."
                }
            }
            try{
                Remove-Item $expandFolder -Recurse -Force -ErrorAction Stop
            }catch{
                return "Can't delete folder, please wait a moment."
            }
        }
        mkdir $expandFolder | Out-Null
        expand -F:* $softwarePath $expandFolder | Out-Null
        $cabFullName = Get-ChildItem $expandFolder | where {$_.FullName -like "*.cab" -and $_.FullName -notlike "*WSUSSCAN.cab"} | foreach {$_.FullName}
        "installing" | Out-File $stateFilePath
        dism.exe /online /add-package /packagepath:"$cabFullName" /quiet /norestart
        "installed" | Out-File $stateFilePath
        Remove-Item $expandFolder -Recurse -Force
        If($LASTEXITCODE -eq 0 ){
            $exitMsg="dism add package success"
        }elseif($LASTEXITCODE -eq -2146498530){
            return "The specified package is not applicable to this image %%SMP:success"
        }elseif($LASTEXITCODE -eq 3010){
            $exitMsg="reboot system is required"
        }elseif($LASTEXITCODE -eq 3){
            return "file path can not be found"
        }elseif($LASTEXITCODE -eq 183){
            return "Another package is installing, please try again later"
        }elseif($LASTEXITCODE -eq 112){
            return "Disk C: space is insufficient"
        }else{
            return "unknown error, exit code is "+$LASTEXITCODE
        }
    }elseif('cab' -eq $Suffix){
        $stateFilePath = $softwarePath.Substring(0,$softwarePath.Length-4) + '_state.txt'
        if(Test-Path $stateFilePath){
            $state = Get-Content $stateFilePath
            if($state -eq "installing"){
                return "Installing patch, please wait a moment."
            }
        }
        "installing" | Out-File $stateFilePath
        dism.exe /online /add-package /packagepath:"$softwarePath" /quiet /norestart
        "installed" | Out-File $stateFilePath
        Remove-Item $stateFilePath -Force
        If($LASTEXITCODE -eq 0 ){
            $exitMsg="dism add package success"
        }elseif($LASTEXITCODE -eq -2146498530){
            return "The specified package is not applicable to this image %%SMP:success"
        }elseif($LASTEXITCODE -eq 3010){
            $exitMsg="reboot system is required"
        }elseif($LASTEXITCODE -eq 3){
            return "file path can not be found"
        }elseif($LASTEXITCODE -eq 183){
            return "Another package is installing, please try again later"
        }elseif($LASTEXITCODE -eq 112){
            return "Disk C: space is insufficient"
        }else{
            return "unknown error, exit code is "+$LASTEXITCODE
        }
    }elseif('exe' -eq $Suffix){
        start "$softwarePath" -Wait -ArgumentList "/quiet /norestart"
	    If(!$?){Return Print-Exception "start `"$softwarePath`" -Wait -ArgumentList `"/quiet /norestart`""}
    }

    #判断补丁是否安装成功
    if (!(Is-KbInstalled($kbNum))){
        if($exitMsg){
            return "This patch fail to install, exit msg: $exitMsg %%SMP:success"
        }else{
            return "This patch fail to install"
        }
    }
    if($exitMsg){
        return "system patch KB$kbNum, exit msg:  $exitMsg %%SMP:success"
    }else{
        return "system patch KB$kbNum %%SMP:success"
    }
}
Function Is-KbInstalled($kbNum){
	$Key='SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages';
	$RegHive=[Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine',$env:COMPUTERNAME);
	$RegKey=$RegHive.OpenSubKey($Key);
	If([string]::IsNullOrEmpty($RegKey)){return $false}
    $parttern="Package_for_KB$kbNum~[a-zA-Z0-9]*~[a-zA-Z0-9]*~~"
    $ret=$false;
    $matched=$false;
	$RegKey.GetSubKeyNames()|ForEach{
        if($_ -match $parttern){
            $matched=$true
            $SubKey=$RegKey.OpenSubKey($_);
            $tmp=$subkey.GetValue('CurrentState');
	        $SubKey.Close()
            if($tmp.gettype().name -eq 'int32'){
				if($tmp -eq 0x70 -or $tmp -eq 0x60  -or $tmp -eq 0x65 ){
                    $ret = $true
                }
			}
        }
    }
    if(!$matched){
        $parttern="Package_for_KB"+$kbNum +"_RTM~[a-zA-Z0-9]*~[a-zA-Z0-9]*~~"
        $RegKey.GetSubKeyNames()|ForEach{
            if($_ -match $parttern){
                $SubKey=$RegKey.OpenSubKey($_);
                $tmp=$subkey.GetValue('CurrentState');
	            $SubKey.Close()
                if($tmp.gettype().name -eq 'int32'){
				    if($tmp -eq 0x70 -or $tmp -eq 0x60  -or $tmp -eq 0x65 ){
                        $ret = $true
                    }
			    }
            }
        }
    }
	$RegHive.Close()
    return $ret;
}