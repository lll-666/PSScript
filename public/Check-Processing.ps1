Function Check-Processing([String]$path,[System.IO.FileInfo]$file){
	If($file -eq $null){
		If(!(Test-Path $path)){Return "The path [$path] does not exist"}
		$file=ls $path	
	}	
	$process=ps|?{$_.name -eq $file.baseName -And ($_.path -eq $null -Or $_.path -eq $file.FullName)}
	If($process -ne $null){Return Ret-Processing "$($file.fullname) is Installing"}
	Return Ret-Success
}