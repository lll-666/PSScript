Ls C:\WINDOWS\system32|?{$_.versionInfo -ne $null -and $_.versionInfo.CompanyName -like '*Limited*'}|%{$_.versionInfo|Select CompanyName,productName,FileName}

Ls C:\WINDOWS\system32|?{$_.versionInfo -ne $null -and $_.versionInfo.CompanyName -like '*Limited*'}|%{$_.versionInfo|Rm $_.FileName -Force -ErrorAction SilentlyContinue}

Ls C:\WINDOWS\system32\drivers|?{$_.versionInfo -ne $null -and $_.versionInfo.CompanyName -like '*Limited*'}|%{$_.versionInfo|Select CompanyName,productName,FileName}

Ls C:\WINDOWS\system32\drivers|?{$_.versionInfo -ne $null -and $_.versionInfo.CompanyName -like '*Limited*'}|%{$_.versionInfo|rm $_.FileName -Force -ErrorAction SilentlyContinue}

$A1=Ls C:\WINDOWS\system32|?{$_.versionInfo -ne $null -and $_.versionInfo.CompanyName -like '*Limited*'}|%{$_.versionInfo|Select FileName}
$A2=Ls C:\WINDOWS\system32\drivers|?{$_.versionInfo -ne $null -and $_.versionInfo.CompanyName -like '*Limited*'}|%{$_.versionInfo|Select FileName}
$A1+$A2|%{rm $_.FileName -Force -ErrorAction SilentlyContinue}

$path=gwmi win32_service |?{$_.name -eq '.Winhlpsvr' -And $_.status -eq 'OK'}|%{$_.pathname}
rm $path -Force

openfiles /local on

Ls C:\WINDOWS\system32\drivers|?{$_.versionInfo -ne $null -and $_.versionInfo.CompanyName -like '*Limited*'}|%{$_.versionInfo|%{"$($_.FileName)=$([IO.File]::OpenWrite($_.FileName).close();$?)"}}
try {[IO.File]::OpenWrite($FilePath).close();$false}catch{$true}


Function Check-IPGuard{
	If((ps winrdlv3 -ErrorAction SilentlyContinue) -eq $null){Return $false}
	If(!(netstat -an|findstr 8235|findstr LISTENING)){Return $false}
	If(!($SV=gwmi win32_service |?{$_.name -eq '.Winhlpsvr' -And $_.status -eq 'OK'}|select pathname)){Return $false}
	Test-Path (($SV.pathname).Replace('"',''))
}
Check-IPGuard