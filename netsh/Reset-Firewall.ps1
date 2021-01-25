Function Reset-Firewall{
	$MpsSvc=Get-Service MpsSvc
	If($MpsSvc.Status -eq 'running'){
		$MpsSvc |Stop-Service
		'防火墙已关闭'
	}elseIf($MpsSvc.Status -eq 'Stopped'){
		 $MpsSvc | Start-Service
		'防火墙已开启'
	}
}