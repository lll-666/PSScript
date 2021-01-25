#Register-ScheduledJob checkWeakPassword -FilePath "C:\Program Files\Ruijie Networks\passdb\Job.ps1" -Trigger @{}
#计算机\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\UASPStor
#为了彻底保护电脑文件和商业机密的安全,除了屏蔽USB还可以禁止电脑发邮件、禁止网盘上传文件、禁止论坛附件上传、禁止FTP上传文件、禁止QQ传文件
#已成型的产品:大势至电脑禁用U盘
#Get-WmiObject -Class CIM_LogicalDevice|select DeviceID,name,Description,Caption,__CLASS,__SUPERCLASS,CreationClassName|Format-Table *
