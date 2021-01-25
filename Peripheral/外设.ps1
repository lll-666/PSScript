Get-WmiObject CIM_LogicalDevice|sort __Class -Unique|Format-Table __Class,__SUPERCLASS,Description,Caption,DeviceID,status

__CLASS                 __SUPERCLASS          Description                                       status
-------                 ------------          -----------                                       ------
Win32_Bus               CIM_LogicalDevice     总线
Win32_CacheMemory       CIM_CacheMemory       缓存                                              OK
Win32_DesktopMonitor    CIM_DesktopMonitor    DELL E2013H (Analog)                              OK
Win32_DiskDrive         CIM_DiskDrive         磁盘驱动器                                        OK
Win32_DiskPartition     CIM_DiskPartition     GPT: 未知
Win32_Fan               CIM_Fan               冷却设备                                          OK
Win32_Keyboard          CIM_Keyboard          USB 输入设备                                      OK
Win32_LogicalDisk       CIM_LogicalDisk       本地固定磁盘
Win32_MemoryArray       Win32_SMBIOSMemory    内存阵列
Win32_MemoryDevice      Win32_SMBIOSMemory    内存设备
Win32_MotherboardDevice CIM_LogicalDevice     主板                                              OK
Win32_NetworkAdapter    CIM_NetworkAdapter    Microsoft Kernel Debug Network Adapter
Win32_PnPEntity         CIM_LogicalDevice     WSD 扫描设备                                      OK
Win32_PointingDevice    CIM_PointingDevice    USB 输入设备                                      OK
Win32_Printer           CIM_Printer                                                             Unknown
Win32_Processor         CIM_Processor         Intel64 Family 6 Model 158 Stepping 10            OK
Win32_SCSIController    CIM_SCSIController    Intel(R) Chipset SATA/PCIe RST Premium Controller OK
Win32_SerialPort        CIM_SerialController  通信端口                                          OK
Win32_SoundDevice       CIM_LogicalDevice     Realtek Audio                                     OK
Win32_TemperatureProbe  CIM_TemperatureSensor CPU Thermal Probe                                 OK
Win32_USBController     CIM_USBController     符合 USB xHCI 的主机控制器                        OK
Win32_USBHub            CIM_USBHub            USB 根集线器(USB 3.0)                             OK
Win32_VideoController   CIM_PCVideoController Intel(R) UHD Graphics 630                         OK
Win32_Volume            CIM_StorageVolume

Win32_Volume
	卷，包含固定磁盘
	
	
Function Kill-ServiceTree([String] $serviceName){
	$service=Get-Service $serviceName
	If($service -eq $null){Return}
	If($service.status -eq 'Disabled'){Return}
	If($service.status -eq 'Stopped'){
		"Set-Service $serviceName -StartupType Disabled">>./log.txt
		$res=Set-Service $serviceName -StartupType Disabled
		If($res -eq $null){
			$error[0].tostring()>>./log.txt;
			Return
		}
	}
	$dependedOn=Get-Service|?{$_.ServicesDependedOn -ne $null -and $_.ServicesDependedOn.name -contains $serviceName}
	If($dependedOn -ne $null){Foreach($d in $dependedOn){Kill-ServiceTree $d.name}}
	"Set-Service $serviceName -StartupType Disabled -Status Stopped ">>./log.txt
	$res=Set-Service $serviceName -StartupType Disabled -Status Stopped
	If($res -eq $null){$error[0].tostring()>>./log.txt;}
}
$ErrorActionPreference='SilentlyContinue'
Kill-ServiceTree

Get-Service ftpsvc|select *
Set-Service ftpsvc -Status Stopped -StartupType Disabled
Get-Service ftpsvc|select *
Set-Service -StartupType Automatic
Get-Service ftpsvc|select *
Set-Service ftpsvc -StartupType Disabled -Status Stopped
Get-Service ftpsvc|select *



Get-Service AppIDSvc|Select Name,CanPauseAndContinue, CanShutdown,CanStop,ServiceName,StartType, Status,ServicesDependedOn
Set-Service AppIDSvc -Status Stopped
Get-Service AppIDSvc|Select Name,CanPauseAndContinue, CanShutdown,CanStop,ServiceName,StartType, Status,ServicesDependedOn
Stop-Service AppIDSvc
Get-Service AppIDSvc|Select Name,CanPauseAndContinue, CanShutdown,CanStop,ServiceName,StartType, Status,ServicesDependedOn
Start-Service AppIDSvc
Get-Service AppIDSvc|Select Name,CanPauseAndContinue, CanShutdown,CanStop,ServiceName,StartType, Status,ServicesDependedOn