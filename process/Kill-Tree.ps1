Function Kill-Tree([int]$ppid){
	Get-WmiObject Win32_Process |?{$_.ParentProcessId -eq $ppid }|%{ Kill-Tree $_.ProcessId }
	Stop-Process -Id $ppid -Force
}