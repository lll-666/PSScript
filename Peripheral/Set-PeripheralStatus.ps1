#计算机\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\UASPStor
#为了彻底保护电脑文件和商业机密的安全,除了屏蔽USB还可以禁止电脑发邮件、禁止网盘上传文件、禁止论坛附件上传、禁止FTP上传文件、禁止QQ传文件
#已成型的产品:大势至电脑禁用U盘
#gwmi -Class CIM_LogicalDevice|select DeviceID,name,Description,Caption,__CLASS,__SUPERCLASS,CreationClassName|Format-Table *
Function Set-PeripheralStatus($status){
	Check-OperateStatus $status -ErrorAction SilentlyContinue
	If(!$?){Return Print-Exception "Set-PeripheralStatus"}
	
	#启用或禁用设备实体
	Set-RemovableDiskIns $status -ErrorAction SilentlyContinue
	
	#启用或禁用[驱动,服务]
	$msg=Set-RemovableDiskDrive $status -ErrorAction SilentlyContinue
	
	If(!$?){$msg}Else{"$msg %%SMP:success"}
}