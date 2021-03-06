#方式一
# set the Windows Update service to "disabled"
sc.exe config wuauserv start=disabled
# display the status of the service
sc.exe query wuauserv
# stop the service, in case it is running
sc.exe stop wuauserv
# display the status again, because we're paranoid
sc.exe query wuauserv
# double check it's REALLY disabled - Start value should be 0x4
REG.exe QUERY HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\wuauserv /v Start#未指定具体值，默认系统缺省值

#方式二
$AUSettings = (New-Object -com "Microsoft.Update.AutoUpdate").Settings
$AUSettings.NotificationLevel = 1
$AUSettings.Save
