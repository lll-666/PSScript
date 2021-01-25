Function Set-NetworkAdapter{
	param([bool] flag);
	$netAda = Get-WmiObject Win32_NetworkAdapter | Where{$_.servicename -eq 'wifimp' -And $_.NetConnectionStatus -eq 2}
	If($netAda -eq $null){
		
	}
	Get-WmiObject Win32_NetworkAdapter
}



Function Check-NetworkAdapter{
	$netAda = Get-WmiObject Win32_NetworkAdapter | Where{$_.servicename -eq 'wifimp' -And $_.NetConnectionStatus -eq 2}
	If($null -eq $netAda){}
}