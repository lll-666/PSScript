Function Test-FileLocked([string]$FilePath) {
	If(!(Test-Path $FilePath)){Return $false}
    try {[IO.File]::OpenWrite($FilePath).close();$false}catch{$true}
}