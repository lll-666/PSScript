$mutexName = 'xxx';
$mutex=$false;
$mutexObj = New-Object System.Threading.Mutex ($true,$mutexName,[ref]$mutex)
if($mutex){
	#避免死锁
	$mutexObj.WaitOne(20000,$false)
    write-host 'start'
    start-sleep  -Seconds 20 
	throw 'open a error'
    $mutexObj.ReleaseMutex() | Out-Null
    $mutexObj.Dispose() | Out-Null
    write-host 'end'
}else{
    write-host 'get lock fail'
}