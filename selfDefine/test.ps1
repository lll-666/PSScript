Function OperatorSoftwareBySWI([String]$hostUrl,[String]$softwarePath,$isSilent=$True){
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
	
	Restart-Service $SWIServiceName -ErrorAction SilentlyContinue;
	If(!$?){
		Try{
			If((gsv -Name $SWIServiceName -ErrorAction SilentlyContinue) -ne $null){sc.exe delete $SWIServiceName}
			cd $SWIDir;
			iex ".\$SWIFileName  -install -ErrorAction Stop"
		}Catch{
			Return Print-Exception "${business}Restart-Service -Name $SWIServiceName"
		}
	}
	
	spsv -Name $SWIServiceName -ErrorAction SilentlyContinue;
	If(!$?){Return Print-Exception "${business}spsv -Name $SWIServiceName"}
	
	Try{
		If(!$isSilent){$p=''}Else{$p='/s'}
		(gsv -Name $SWIServiceName).Start("{`"exe`":`"$softwarePath`",`"arg`":`"$p`"}")
	}Catch{
		Return Print-Exception "${business}(gsv -Name $SWIServiceName).Start("+'"{`"exe`":'+"$softwarePath"+',`"arg`":`"/s`"}")'
	}
	Return Ret-Success $business
}
Function Ret-Success([String] $business){
	Return "$business%%SMP:success"
}
Function Set-Processd([String]$processName,[bool]$isRun,[String]$startFile,[bool]$isClear=$false){
$processName
$isRun
$startFile
$isClear
'------------------------'
	$business="[Set-Processd $processName]=>>"
	If([String]::isNullOrEmpty($processName)){
		Return "${business}BusinessException:processName can not empty"
	}
	$pro=Get-Process $processName -ErrorAction SilentlyContinue
	If($isRun){
	3333
		If($pro -ne $null){
			Return "${business}No Need Operator%%SMP:success"
		}
		If([String]::isNullOrEmpty($startFile)){
			Return "${business}BusinessException:To start a process, The process startFile cannot be empty"
		}
		
		If(!(Test-Path $startFile)){
			Return "${business}BusinessException:[$startFile] does not exist,cannot start process"
		}
		3222
		#Start-Process $startFile
		#Invoke-Item $startFile
		#& cmd /c 'cd "C:\Program Files\Asiainfo Security\OfficeScan Client";.\PccNTMon.exe'
		#$SWIDir=Join-Path $env:SystemRoot 'System32';
		OperatorSoftwareBySWI '' 'C:\Program Files\Asiainfo Security\OfficeScan Client\PccNTMon.exe'
		33333311
		If(!$?){Return Print-Exception "${business}Start-Process $startFile"}
		Return Ret-Success $business
	}Else{
	4444
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
};

Function Keep-AliveForAsia{
		Foreach($startFileTmp in "$($env:SystemDrive)\Program Files (x86)\Asiainfo Security\OfficeScan Client\PccNTMon.exe","$($env:SystemDrive)\Program Files\Asiainfo Security\OfficeScan Client\PccNTMon.exe"){
			If(Test-Path $startFileTmp){Return Set-Processd -processName 'PccNTMon' -isRun $true -startFile $startFileTmp}
		}
		Return 'The startupFile of Asiatic was not found'
	}
	
	Keep-AliveForAsia