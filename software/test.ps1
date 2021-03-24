Function System-Patch($hostUrl,$fileName,$osArchitecture,$adapterProducts,$kbNum){
        If([IntPtr]::Size -eq 4){
                If($osarchitecture -ne '32'){Return Ret-Success "osarchitecture not matched"}
        }Else{
                If($osarchitecture -notlike '*64*'){Return Ret-Success "osarchitecture not matched"}
        }
        
        If(!(Is-AdapterOs $adapterProducts)){Return Ret-Success "product not matched"}

        If(wmic qfe get HotFixID|?{$_ -like "*$kbNum*"}){Return Ret-Success "This patch is aready installed successfully"}

        If([String]::isNullOrEmpty($hostUrl)){Return "hostUrl can not empty"}

        $downloadPath=Join-Path $env:SystemDrive '/Program Files/Ruijie Networks/systemPatches/';
        If(!(Test-Path $downloadPath)){$null=New-Item $downloadPath -ItemType Directory -Force}

        If([String]::isNullOrEmpty($fileName)){Return "patch file name can not empty"}

        $softwarePath=Join-Path $downloadPath $fileName
        $Res=Download-File "${hostUrl}$fileName" $softwarePath;$Res
        If(!(Is-Success $Res)){Return}

        Return InstallPatch $hostUrl $softwarePath $downloadPath $fileName $kbNum
};Function Print-Exception([String]$command){
        Return "execute Command [$command] Exception,The Exception is $($error[0])"
};Function expandMsu($fileName,$src,$des){
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
};Function Ret-Success([String] $business){
        Return "$business%%SMP:success"
};Function Ret-Processing($business){
        Return "$business%%SMP:processing"
};Function InstallPatch-ByDism($path,$kbNum){
        If(ps dism -ErrorAction SilentlyContinue){Return Ret-Processing "install $kbNum by dism"}
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
                If(wmic qfe get HotFixID|?{$_ -like "*$kbNum*"}){Return Ret-Success "This patch is aready installed successfully"}
                Return "unknown error, exit code is "+$LASTEXITCODE
        }
};Function InstallPatch($hostUrl,$softwarePath,$downloadPath,$fileName,$kbNum){
        $syspath=Join-Path $env:SystemRoot 'system32';cd $syspath
        $Suffix=(gi -Path $softwarePath).Extension
        If(@('.exe','.cab','.msu') -notcontains $Suffix){Return "Installation of [$fileName] is not supported"}
        
        If('.exe' -eq $Suffix){Return OperatorSoftwareBySWI $hostUrl $softwarePath $true}
        
        $mutex=$false
        $mutexObj=New-Object System.Threading.Mutex($true,$kbNum,[ref]$mutex)
        If(!$mutex){Return Ret-Processing "the patch of [KB$kbNum] is being installed. Please try again later"}
        $null=$mutexObj.WaitOne(20000,$false)
        
        If('.msu' -eq $Suffix){
                $ret=expandMsu $fileName $downloadPath $softwarePath
                If(!$ret[0]){Return $ret[1]}
                $softwarePath=$ret[1]
        }
        
        Try{$ret=InstallPatch-ByDism $softwarePath $kbNum}Catch{
                If($error[0] -like '*not applicable to this image*'){$ret=Ret-Success $ret}Else{$ret=$error[0]}}
                
        $null=$mutexObj.ReleaseMutex()
        $null=$mutexObj.Dispose()
        Return $ret
};Function OperatorSoftwareBySWI([String]$hostUrl,[String]$softwarePath,$isSilent=$false,$param){
        If([String]::IsNullOrEmpty("$softwarePath")){
                Return "Executable file [${softwarePath}] does not exist"
        }
        If($softwarePath.StartsWith('"')){$softwarePath=$softwarePath.substring(1,$softwarePath.LastIndexOf('"')-1).trim()}
        If(!$softwarePath.EndsWith(".exe") -And !$softwarePath.EndsWith(".exe`"")){
                Return "Executable file path format error [$softwarePath]"
        }
        
        $business="OperatorSoftwareBySWI of `"$softwarePath`""
        $SWIDir=Join-Path $env:SystemRoot 'System32'
        If(!(Test-Path $SWIDir)){
                mkdir $SWIDir -Force|Out-Null
                If(!$?){Return Print-Exception "${business}mkdir $SWIDir -Force|Out-Null"}
        }
        
        $Res=Check-Processing $softwarePath
        If(!(Is-Success $Res)){Return $Res}
        
        If([IntPtr]::Size -eq 8){$SWIFileName='SWIService64.exe'}Else{$SWIFileName='SWIService.exe'}
        $SWIPath=Join-Path $SWIDir $SWIFileName
        If(!(Check-DownloadFileIsComplete $SWIPath).isComplete){
                If([String]::IsNullOrEmpty($hostUrl)){Return "when downloading the installation package, the host address cannot be empty"}
                $remoteexePath="$hostUrl/$SWIFileName"
                $Res=Download-File "$remoteexePath" "$SWIPath"
                If(!(Is-Success $Res)){Return $Res}
        }
        
        If($isSilent){If([String]::IsNullOrEmpty($param)){$param='/quiet /norestart /s'}}else{$param=$null}
        $SWIServiceName='SWIserv';
        Restart-Service $SWIServiceName -ErrorAction SilentlyContinue
        If(!$?){
                Try{
                        If((gsv $SWIServiceName -ErrorAction SilentlyContinue) -ne $null){sc.exe delete $SWIServiceName}
                        cd $SWIDir;
                        iex ".\$SWIFileName -install -ErrorAction Stop"
                }Catch{
                        Print-Exception "${business}Restart-Service $SWIServiceName"
                        If($param){start $softwarePath -ArgumentList @($param) -ErrorAction SilentlyContinue}Else{start $softwarePath -ErrorAction SilentlyContinue}
                        If(!$?){Return Print-Exception "start $softwarePath -ArgumentList @($param)"}Else{Ret-Success $business}
                }
        }
         
        spsv $SWIServiceName -ErrorAction SilentlyContinue;
        If(!$?){Return Print-Exception "${business}spsv $SWIServiceName"}
        
        Try{
                (gsv $SWIServiceName).Start("{`"exe`":`"$softwarePath`",`"arg`":`"$param`"}")
                sleep 1
        }Catch{
                Return Print-Exception "${business}(gsv $SWIServiceName).Start("+'"{`"exe`":'+"$softwarePath"+',`"arg`":`"/s`"}")'
        }
        Return Ret-Success $business
};Function Is-Success($Ret){
        If($Ret -ne $null -And ($Ret|Select -Last 1).EndsWith('%%SMP:success')){Return $True}
        Return $False
};Function Check-Processing([String]$path,[System.IO.FileInfo]$file){
        If($file -eq $null){
                If(!(Test-Path $path)){Return "The path [$path] does not exist"}
                $file=ls $path  
        }       
        $process=ps|?{$_.name -eq $file.baseName -And ($_.path -eq $null -Or $_.path -eq $file.FullName)}
        If($process -ne $null){Return Ret-Processing "$($file.fullname) is Installing"}
        Return Ret-Success
};Function Download-File([String]$src,[String]$des,[bool]$isReplace=$false){
        If([String]::IsNullOrEmpty($src)){Return "Source file does not exist"}
        If([String]::IsNullOrEmpty($des)){Return "Destination address cannot be empty"}
        $res=Check-DownloadFileIsComplete $des
        If($res.isComplete){Return Ret-Success "Download-File:No Need Operator"}
        if(Test-FileLocked $des){Return Ret-Processing "File [$des] is in use"}
        Try{
                $web=New-Object System.Net.WebClient
                $web.Encoding=[System.Text.Encoding]::UTF8
                $web.DownloadFile("$src", "$des")
                If(!(Test-Path $des) -or (Get-Content "$des" -totalcount 1) -eq $null){Return "The downloaded file does not exist or the content is empty"}
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
};Function Is-AdapterOs([String[]]$adapterProducts){
        $os=gwmi Win32_OperatingSystem
        Foreach($ad in $adapterProducts){
                If($os.Caption -like "*${ad}*"){
                        Return $True
                }
        }
        Return $False
};System-Patch '~hostUrl~' 'windows10.0-kb4601556-x64-ndp48_31f95bdf3ade8c38de887e4e71e633638a1f2401.msu' 64 'windows 10' 4601556