#Get-CimInstance Win32_Process|Select-Object ProcessName,Description,ParentProcessId,ProcessId|Sort-Object ParentProcessId

$name='powershell'
Function AAA($process){
	$process|select ParentProcessId,ProcessId,ProcessName
	If($process.ProcessId -eq $process.ParentProcessId){return}
	Get-CimInstance Win32_Process|?{$_.ProcessId -eq $process.ParentProcessId}|%{AAA $_}
}
Get-CimInstance Win32_Process|?{$_.ProcessName -eq $("$name.exe")}|%{AAA $_}

<#
$com='c:\windows\system32\calc.exe'
$shell = new ActiveXObject( 'W.Shell' );
$shell.Run("powershell.exe Invoke-Item $com" );
#>