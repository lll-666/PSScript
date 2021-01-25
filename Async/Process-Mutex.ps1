$mutexName = 'xxx';
$mutex=$false;
$mutexObj = New-Object System.Threading.Mutex ($true,$mutexName,[ref]$mutex)
if($mutex){
    write-host '互斥成功，开始干活!'
    start-sleep  -Seconds 60 #你的任务
    $mutexObj.ReleaseMutex() | Out-Null
    $mutexObj.Dispose() | Out-Null
    write-host '活干完了，释放'
}else{
	# 每个互斥脚本必须单独占用一个进程！powershell传教士 win7 ,win10, powershell core v6.0 beta8 on linux测试通过
    write-host '互斥失败 !'
}