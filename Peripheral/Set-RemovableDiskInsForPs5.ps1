Function Set-RemovableDiskInsForPs5($status){
	check-OperateStatus $status
	If('disable' -eq $status){
		Get-PnpDevice|?{$_.Class -eq 'WPD'  -and $_.Status -eq 'ok'}|Disable-PnpDevice -Confirm:$false
	}Else{
		Get-PnpDevice|?{$_.Class -eq 'WPD'  -and $_.Status -eq 'error'}|Enable-PnpDevice -Confirm:$false
	}
}

Foreach($t in 1..100){
Get-Process |where{$_.Company -like 'TEC Solutions Limited.'}|sort id|select -First 1|%{taskkill /pid $_.id /t /f;}
sleep 1
}


Get-Process |where{$_.Company -like 'TEC Solutions Limited.'}|sort id|select -First 1|%{taskkill /pid $_.id /t /f;Ls C:\WINDOWS\system32|
	Where{$_.versionInfo -ne $null -and $_.versionInfo.CompanyName -like '*Limited*'}|
	%{ $tmp=$_.versionInfo|Select CompanyName,productName,FullName; $tmp.FullName=$_.FullName;$tmp }|del}