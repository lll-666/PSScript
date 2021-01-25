Function Config-TightVNC{
	Param(
		[Parameter(Mandatory=$true)]$RegPath,[bool]$IsReplace=$True,[String]$Password,[String]$ControlPassword,[String]$PasswordViewOnly,
		[String]$QueryTimeout,[String]$ExtraPorts,[String]$QueryAcceptOnTimeout,[String]$LocalInputPriorityTimeout,[String]$LocalInputPriority,
		[String]$BlockRemoteInput,[String]$BlockLocalInput,[String]$IpAccessControl,[String]$RfbPort,[String]$HttpPort,[String]$DisconnectAction,
		[String]$AcceptRfbConnections,[String]$UseVncAuthentication,[String]$UseControlAuthentication,[String]$RepeatControlAuthentication,
		[String]$LoopbackOnly,[String]$AcceptHttpConnections,[String]$LogLevel,[String]$EnableFileTransfers,[String]$RemoveWallpaper,[String]$UseMirrorDriver,
		[String]$EnableUrlParams,[String]$AlwaysShared,[String]$NeverShared,[String]$DisconnectClients,[String]$PollingInterval,[String]$AllowLoopback,
		[String]$VideoRecognitionInterval,[String]$GrabTransparentWindows,[String]$SaveLogToAllUsersPath,[String]$RunControlInterface,[String]$VideoClasses
	)

	$DefautV=@{
		Password='Binary:@(15,224,193,197,37,128,73,235)';ControlPassword='Binary:@(15,224,193,197,37,128,73,235)';PasswordViewOnly='Binary:@(15,224,193,197,37,128,73,235)';
		QueryTimeout='Dword:30';ExtraPorts='String:';QueryAcceptOnTimeout='Dword:0';
		LocalInputPriorityTimeout='Dword:3';LocalInputPriority='Dword:0';BlockRemoteInput='Dword:0';
		BlockLocalInput='Dword:0';IpAccessControl='String:';RfbPort='Dword:5900';
		HttpPort='Dword:5800';DisconnectAction='Dword:0';AcceptRfbConnections='Dword:1';
		UseVncAuthentication='Dword:1';UseControlAuthentication='Dword:1';RepeatControlAuthentication='Dword:0';
		LoopbackOnly='Dword:0';AcceptHttpConnections='Dword:1';LogLevel='Dword:0';
		EnableFileTransfers='Dword:1';RemoveWallpaper='Dword:1';UseMirrorDriver='Dword:1';
		EnableUrlParams='Dword:1';AlwaysShared='Dword:0';NeverShared='Dword:0';
		DisconnectClients='Dword:1';PollingInterval='Dword:1000';AllowLoopback='Dword:0';
		VideoRecognitionInterval='Dword:3000';GrabTransparentWindows='Dword:1';SaveLogToAllUsersPath='Dword:0';
		RunControlInterface='Dword:1';VideoClasses='String:'
	}
	
	$IsChange=$False 
	If(!(Test-Path $RegPath)){$null=md $RegPath -Force -ErrorAction SilentlyContinue}
	$reg=gi $RegPath
	$pks=$PSBoundParameters.keys
	#处理上送参数
	Foreach($pk in $pks){
		$dm=$DefautV.$pk
		If(!$dm){Continue}
		$DefautV.remove($pk)
		$pv=$PSBoundParameters[$pk]
		$rv=$reg.GetValue($pk)
		$dt=$dm.split(':')[0]
		If('Binary' -eq $dt){
			If($rv -eq $null){$rv=''}
			If($pv -eq ($rv -join '-')){Continue}
			$pv=$pv.split('-')
		}Else{If($pv -eq $rv){Continue}}
		If($IsReplace){sp $RegPath -Name $pk -Value $pv -Type $dt;$IsChange=$True}
	}
	
	$dks=$DefautV.keys
	#处理默认参数（若默认值不存在，会影响整体功能）
	Foreach($dk in $dks){
		If($reg.GetValue($dk) -ne $null){Continue}
		$arr=$DefautV.$dk.split(':')
		$dt=$arr[0]
		$dv=$arr[1]
		If('Binary' -eq $dt){$dv=iex "$($arr[1])"}
		sp $RegPath -Name $dk -Value $dv -Type $dt
		$IsChange=$True
	}
	Return $IsChange
}