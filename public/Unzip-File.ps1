Function Unzip-File{
    param([string]$ZipFile,[string]$TargetFolder)
    #确保目标文件夹必须存在
    If(!(Test-Path $TargetFolder)){mkdir $TargetFolder}
	
    $shellApp = New-Object -ComObject Shell.Application
    $files = $shellApp.NameSpace($ZipFile).Items()
    $shellApp.NameSpace($TargetFolder).CopyHere($files)
}


(New-Object -comObject Shell.Application).Windows()| where {($_.FullName -ne $null) -and ($_.FullName.toLower().EndsWith("iexplore.exe")) }| foreach { $_.quit() }