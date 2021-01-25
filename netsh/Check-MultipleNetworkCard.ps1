Function Unified-Return([Object[]]$msgs,[Parameter(Mandatory = $true)][String]$business){
	If($msgs -eq $Null -Or $msgs.count -eq 0){
		$isSuccess='false';
		$msg='No message returned';
	}Else{
		If(($msgs[-1]).EndsWith('%%SMP:success')){
			$isSuccess='true';
		}Else{
			$isSuccess='false';
		}
		$msg=($msgs -Join ';	').replace('\','/')
	}
	Return "{`"isSuccess`":`"$isSuccess`",`"msg`":`"$msg`",`"business`":`"$business`"}";
}

Function Check-MultipleNetworlCard{
	$netAdpter=Get-WmiObject -Class win32_networkadapter |?{$_.NetEnabled -eq $true -and $_.serviceName -ne 'VMnetAdapter'}|Select Name,MACAddress,NetEnabled,ServiceName
	#Get-WmiObject win32_networkadapterconfiguration |Select Description,DHCPEnabled,IPAddress,IPConnectionMetric,IPEnabled,serviceName
	#Name,AdapterType,AdapterTypeId,Description,MACAddress,Manufacturer,NetEnabled,PhysicalAdapter,PNPDeviceID,ServiceName,NetConnectionID
	If($netAdpter -ne $null -And $netAdpter.count -gt 1){
		Return "Currently, the network card information available on the Internet is {$netAdpter}","There are multiple network cards on the terminal to access the Internet"
	}
	Return "Currently, the network card information available on the Internet is {$netAdpter}","%%SMP:success"
}
Unified-Return -msgs (Check-MultipleNetworlCard) -business 'Check-MultipleNetworlCard'