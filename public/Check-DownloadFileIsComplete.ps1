Function Check-DownloadFileIsComplete($FilePath){
	$isComplete=$false
	If(Test-Path $FilePath){
		$file=gi $FilePath
		$endFilePath=Join-Path $file.DirectoryName "$($file.basename)_end"
		$isComplete=Test-Path $endFilePath
	}
	Return New-Object PSObject -Property @{isComplete=$isComplete;endFilePath=$endFilePath;filePath=$FilePath}
}