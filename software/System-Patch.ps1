Function Download-File([String]$src,[String]$des,[bool]$isReplace=$false){
	If([String]::IsNullOrEmpty($src)){Return "Source file does not exist"}
	If([String]::IsNullOrEmpty($des)){Return "Destination address cannot be empty"}
	$res=Check-DownloadFileIsComplete $des
	If($res.isComplete){Return Ret-Success "Download-File:No Need Operator"}
	If(Test-FileLocked $des){Return Ret-Processing "File [$des] is in use"}
	Try{
		$web=New-Object System.Net.WebClient
		$web.Encoding=[System.Text.Encoding]::UTF8
		$web.DownloadFile("$src", "$des")
		If(!(Test-Path $des) -or (cat "$des" -totalcount 1) -eq $null){Return "The downloaded file does not exist or the content is empty"}
		If([String]::IsNullOrEmpty($res.endFilePath)){$res=Check-DownloadFileIsComplete $des}
		New-Item -Path $res.endFilePath -ItemType "file"|Out-Null
	}Catch{Return Print-Exception "$web.DownloadFile($src,$des)"}
	Return Ret-Success "Download-File"
}
Function Ret-Success([String] $business){
	Return "$business%%SMP:success"
}
Function Ret-Processing($business){
	Return "$business%%SMP:processing"
}

Function Is-KbInstalled($kbNum){
	$qfe=wmic qfe get HotFixID
	If($qfe|?{$_ -like "KB${kbNum}*"}){Return $true}
	If(($qfe|select -first 1) -like 'HotFixID*'){Return $false}
	
	$Key='SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages';
	$RegHive=[Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine',$env:COMPUTERNAME);
	$RegKey=$RegHive.OpenSubKey($Key);
	If([string]::IsNullOrEmpty($RegKey)){Return $false}
	$names=$RegKey.GetSubKeyNames()
	$matched=$false
	ForEach($_ in $names){
		If($_ -match "Package_for_KB${kbNum}~[a-zA-Z0-9]*~[a-zA-Z0-9]*~~"){
			$matched=$true
			$SubKey=$RegKey.OpenSubKey($_);
			$tmp=$subkey.GetValue('CurrentState');
			$SubKey.Close()
			If($tmp.gettype().name -eq 'int32'){
				If($tmp -eq 0x70 -or $tmp -eq 0x60  -or $tmp -eq 0x65 ){Return $true}
			}
		}
	}
	
	If(!$matched){
		ForEach($_ in $names){
			If($_ -match "Package_for_KB${kbNum}_RTM~[a-zA-Z0-9]*~[a-zA-Z0-9]*~~"){
				$SubKey=$RegKey.OpenSubKey($_);
				$tmp=$subkey.GetValue('CurrentState');
				$SubKey.Close()
				If($tmp.gettype().name -eq 'int32'){
					If($tmp -eq 0x70 -or $tmp -eq 0x60  -or $tmp -eq 0x65 ){Return $true}
				}
			}
		}
	}
	$RegHive.Close()
	return $false
}

Function Print-Exception([String]$command){
	Return "execute Command [$command] Exception,The Exception is $($error[0])"
}
Function Check-DownloadFileIsComplete($FilePath){
	$isComplete=$false
	If(Test-Path $FilePath){
		$file=gi $FilePath
		$endFilePath=Join-Path $file.DirectoryName "$($file.basename)_end"
		$isComplete=Test-Path $endFilePath
	}
	Return New-Object PSObject -Property @{isComplete=$isComplete;endFilePath=$endFilePath;filePath=$FilePath}
}
Function Is-Success($Ret){
	If($Ret -ne $null -And ($Ret|Select -Last 1).EndsWith('%%SMP:success')){Return $True}
	Return $False
}
Function Test-FileLocked([string]$FilePath) {
    try {[IO.File]::OpenWrite($FilePath).close();$false}catch{$true}
}
Function Check-Processing([String]$path,[System.IO.FileInfo]$file){
	If($file -eq $null){
		If(!(Test-Path $path)){Return "The path [$path] does not exist"}
		$file=ls $path	
	}	
	$process=ps|?{$_.name -eq $file.baseName -And ($_.path -eq $null -Or $_.path -eq $file.FullName)}
	If($process -ne $null){Return Ret-Processing "$($file.fullname) is Installing"}
	Return Ret-Success
}

Function System-Patch($hostUrl,$fileName,$osArchitecture,$adapterProducts,$kbNum){
	$os=gwmi Win32_OperatingSystem
	$isMatch=$false
	Foreach($ad in $adapterProducts){If($os.Caption -like "*${ad}*"){$isMatch=$true;Break}}
	
	If(!$isMatch){Return Ret-Success "product not matched"}
	
	If(($osarchitecture -like '*IA*' -And $env:PROCESSOR_ARCHITECTURE -ne 'IA64') -or $os.osarchitecture -notlike "${osArchitecture}*"){
		return Ret-Success "osarchitecture not matched"
	}
	
	If(Is-KbInstalled $kbNum){Return Ret-Success "This patch is aready installed successfully"}

	If([String]::isNullOrEmpty($hostUrl)){Return "hostUrl can not empty"}

	$downloadPath=Join-Path $env:SystemDrive '/Program Files/Ruijie Networks/systemPatches/';
	If(!(Test-Path $downloadPath)){$null=New-Item $downloadPath -ItemType Directory -Force}

	If([String]::isNullOrEmpty($fileName)){Return "patch file name can not empty"}

	$softwarePath=Join-Path $downloadPath $fileName
	$Res=Download-File "${hostUrl}$fileName" $softwarePath;$Res
	If(!(Is-Success $Res)){Return}

	Return InstallPatch $hostUrl $softwarePath $downloadPath $fileName $kbNum
}

Function InstallPatch($hostUrl,$softwarePath,$downloadPath,$fileName,$kbNum){
	$Suffix=(gi -Path $softwarePath).Extension
	If(@('.exe','.cab','.msu') -notcontains $Suffix){Return "Installation of [$fileName] is not supported"}
	
	If('.exe' -eq $Suffix){Return OperatorSoftwareBySWI $hostUrl $softwarePath $true}
	
	cd (Join-Path $env:SystemRoot 'system32')
	If('.msu' -eq $Suffix){
		#校验锁
		$lockPath=Join-Path $downloadPath "${kbNum}_lock"
		If(Test-Path $lockPath){
			$date=(gi $lockPath).LastWriteTime
			$now=Get-date
			If($date.AddMinutes(30) -ge $now){
				If($date.AddMinutes(3) -le $now){
					If(ps dism -ErrorAction SilentlyContinue){Return Ret-Processing "Installing patch $kbNum by dism"}
				}Else{
					Return Ret-Processing "the patch of [KB$kbNum] is being installed. Please try again later"
				}
			}
			rm $lockPath -Force
		}
		
		#加锁
		$null=ni $lockPath -Force
		
		$res=ExpandAndInstall-ByDism $fileName $downloadPath $softwarePath

		#删除锁
		$null=rm $lockPath -Force
		Return $res
	}
	Return InstallPatch-ByDism $softwarePath $kbNum
}

Function ExpandAndInstall-ByDism($fileName,$downloadPath,$softwarePath){
	$ret=expandMsu $fileName $downloadPath $softwarePath
	If(!$ret[0]){Return $ret[1]}
	$softwarePath=$ret[1]
	Return InstallPatch-ByDism $softwarePath $kbNum
}

Function expandMsu($fileName,$src,$des){
	If($fileName.Split("_").Count -eq 1){
		$expandFolder=$src + $fileName.Substring(0, $fileName.LastIndexOf('.'))
	}Else{
		$expandFolder=$src + $fileName.Split("_")[0]
	}
	If(Test-Path $expandFolder){
		try{rm $expandFolder -Recurse -Force -ErrorAction Stop}catch{Return @($false,(Ret-Processing "Installing patch, please wait a moment."))}}
	$null=mkdir $expandFolder -Force
	$null=.\expand -F:* $des $expandFolder
	Return @($true,(ls $expandFolder|?{$_.Extension -eq '.cab' -and $_.name -notlike "*WSUSSCAN.cab"}|Select -First 1|%{$_.FullName}))
}

Function InstallPatch-ByDism($path,$kbNum){
	If(ps dism -ErrorAction SilentlyContinue){Return Ret-Processing "Installing patch $kbNum by dism"}
	Try{
		$null=.\dism.exe /online /add-package /packagepath:"$path" /quiet /norestart
		If($LASTEXITCODE -eq 0 ){
			Return Ret-Success "dism add package success"
		}Elseif($LASTEXITCODE -eq -2146498530){
			Return Ret-Success "The specified package is not applicable to this image"
		}Elseif($LASTEXITCODE -eq 3010){
			Return Ret-Success "reboot system is required"
		}Elseif($LASTEXITCODE -eq 3){
			Return "file path can not be found"
		}Elseif($LASTEXITCODE -eq 183){
			Return Ret-Success "The specified package is not applicable to this image"
		}Else{
			If(Is-KbInstalled $kbNum){Return Ret-Success "This patch is aready installed successfully"}
			Return "unknown error, exit code is "+$LASTEXITCODE
		}
	}Catch{
		If($error[0] -like '*not applicable to this image*'){Return Ret-Success $error[0]}
		Else{Return $error[0]}
	}
}
System-Patch '~hostUrl~' 'windows10.0-kb4601556-x64-ndp48_31f95bdf3ade8c38de887e4e71e633638a1f2401.msu' 64 'windows 10' 4601556
<#
wmic qfe get HotFixID|?{$_ -like "*5000808*"}
wmic qfe get HotFixID|?{$_ -like "*4601556*"}
. F:\PSScript\software\System-Patch.ps1
System-Patch 'host' 'windows10.0-kb4601556-x64-ndp48_31f95bdf3ade8c38de887e4e71e633638a1f2401.msu' 64 'Windows 10' 4601556
System-Patch 'host' 'windows10.0-kb5000808-x64_e574cea84cade2730bfdd398cc341dbe0b864cbe.msu' 64 'Windows 10' 5000808
#>