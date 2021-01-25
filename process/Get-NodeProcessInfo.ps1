Get-WmiObject Win32_Process|Select-Object CommandLine,ParentProcessId,ProcessId|Sort-Object ParentProcessId|ForEach-Object{
	$process=Get-Process -Id $_.ProcessId|Select-Object ParentProcessId,ProcessId,ProcessName,StartTime,Product,Path,CommandLine,ProductVersion,Company,Description -ErrorAction SilentlyContinue;
	If($?){
		$process.ParentProcessId=$_.ParentProcessId;
		$process.ProcessId=$_.ProcessId;
		$process.CommandLine=$_.CommandLine;
		$process
	}
}
