If(Test-Path "$($env:SystemDrive)\Program Files (x86)\Asiainfo Security\OfficeScan Client\PccNTMon.exe"){
	$startFile="$($env:SystemDrive)\Program Files (x86)\Asiainfo Security\OfficeScan Client\PccNTMon.exe"
}ElseIf(Test-Path "$($env:SystemDrive)\Program Files\Asiainfo Security\OfficeScan Client\PccNTMon.exe"){
	$startFile="$($env:SystemDrive)\Program Files\Asiainfo Security\OfficeScan Client\PccNTMon.exe"
}
If([String]::isNullOrEmpty($startFile)){Return "To start a process, The process startFile cannot be empty"}
If(!(Test-Path $startFile)){Return "[$startFile] does not exist,cannot start process"}
sc create AsiainfoSVC binpath= $startFile type= own start= auto displayname= "Asiainfo Security"
#sc create services binpath= $startFile type= own start= demand displayname= "Asiainfo Security" depend= iisadmin/Schedule