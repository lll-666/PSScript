Function Download-File([String]$src,[String]$des,[bool]$isReplace=$false){
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
}