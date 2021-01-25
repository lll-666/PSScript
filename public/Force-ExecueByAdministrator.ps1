param( $a, $b )
#region #关键代码：强迫以管理员权限运行
$currentWi = [Security.Principal.WindowsIdentity]::GetCurrent()
$currentWp = [Security.Principal.WindowsPrincipal]$currentWi
if(-not $currentWp.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){
	$boundPara=($MyInvocation.BoundParameters.Keys | foreach{'-{0} {1}' -f $_,$MyInvocation.BoundParameters[$_]}) -join ' '
	$currentFile=(Resolve-Path $MyInvocation.InvocationName).Path
	#两种方式都行
	#$currentFile=$MyInvocation.MyCommand.Definition
	$fullPara = $boundPara + ' ' + $args -join ' '
	Start-Process "$psHome\powershell.exe"	-ArgumentList "$currentFile $fullPara"	-verb runas -WindowStyle Hidden
	return
}
#endregion
#region 测试脚本片段
Write-Host '执行完毕,按任意键退出...'
Read-Host
#endregion