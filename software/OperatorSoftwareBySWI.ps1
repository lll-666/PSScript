Function OperatorSoftwareBySWI([String]$hostUrl,[String]$softwarePath,$isSilent=$false,$param){
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
}