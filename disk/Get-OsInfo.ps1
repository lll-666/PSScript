$isGt3=($PSVersionTable|%{$_.PSVersion}|%{$_.Major}) -gt 2

# 获取系统的BIOS的信息
Get-WMIObject -Class Win32_BIOS
<#
BiosCharacteristics            : {7, 9, 11, 12...}
BIOSVersion                    : {DELL   - 1072009, 1.3.3, American Megatrends - 5000D}
BuildNumber                    :
Caption                        : 1.3.3
CodeSet                        :
CurrentLanguage                : en|US|iso8859-1
Description                    : 1.3.3
EmbeddedControllerMajorVersion : 255
EmbeddedControllerMinorVersion : 255
IdentificationCode             :
InstallableLanguages           : 2
InstallDate                    :
LanguageEdition                :
ListOfLanguages                : {en|US|iso8859-1, }
Manufacturer                   : Dell Inc.
Name                           : 1.3.3
OtherTargetOS                  :
PrimaryBIOS                    : True
PSComputerName                 : R09872
ReleaseDate                    : 20180519000000.000000+000
SerialNumber                   : 6QND8Q2
SMBIOSBIOSVersion              : 1.3.3
SMBIOSMajorVersion             : 3
SMBIOSMinorVersion             : 1
SMBIOSPresent                  : True
SoftwareElementID              : 1.3.3
SoftwareElementState           : 3
Status                         : OK
SystemBiosMajorVersion         : 1
SystemBiosMinorVersion         : 3
TargetOperatingSystem          : 0
Version                        : DELL   - 1072009
#>

# 获取内存信息：　
Get-WMIObject -Class Win32_PhysicalMemory
<#
Attributes           : 1
BankLabel            :
Capacity             : 8589934592
Caption              : 物理内存
ConfiguredClockSpeed : 2400
ConfiguredVoltage    : 1200
CreationClassName    : Win32_PhysicalMemory
DataWidth            : 64
Description          : 物理内存
DeviceLocator        : DIMM1
FormFactor           : 8
HotSwappable         :
InstallDate          :
InterleaveDataDepth  : 1
InterleavePosition   : 1
Manufacturer         : 01980000830B
MaxVoltage           : 0
MemoryType           : 0
MinVoltage           : 0
Model                :
Name                 : 物理内存
OtherIdentifyingInfo :
PartNumber           : KHX2400C15/8G
PositionInRow        : 1
PoweredOn            :
PSComputerName       : R09872
Removable            :
Replaceable          :
SerialNumber         : EC2BAF67
SKU                  :
SMBIOSMemoryType     : 26
Speed                : 2400
Status               :
Tag                  : Physical Memory 0
TotalWidth           : 64
TypeDetail           : 128
Version              :
#>

# 获取CPU信息
Get-WMIObject -Class Win32_Processor
<#
AddressWidth                            : 64
Architecture                            : 9
AssetTag                                :
Availability                            : 3
Caption                                 : Intel64 Family 6 Model 158 Stepping 10
Characteristics                         : 252
ConfigManagerErrorCode                  :
ConfigManagerUserConfig                 :
CpuStatus                               : 1
CreationClassName                       : Win32_Processor
CurrentClockSpeed                       : 3192
CurrentVoltage                          : 10
DataWidth                               : 64
Description                             : Intel64 Family 6 Model 158 Stepping 10
DeviceID                                : CPU0
ErrorCleared                            :
ErrorDescription                        :
ExtClock                                : 100
Family                                  : 198
InstallDate                             :
L2CacheSize                             : 1536
L2CacheSpeed                            :
L3CacheSize                             : 12288
L3CacheSpeed                            : 0
LastErrorCode                           :
Level                                   : 6
LoadPercentage                          : 15
Manufacturer                            : GenuineIntel
MaxClockSpeed                           : 3192
Name                                    : Intel(R) Core(TM) i7-8700 CPU @ 3.20GHz
NumberOfCores                           : 6
NumberOfEnabledCore                     : 6
NumberOfLogicalProcessors               : 12
OtherFamilyDescription                  :
PartNumber                              :
PNPDeviceID                             :
PowerManagementCapabilities             :
PowerManagementSupported                : False
ProcessorId                             : BFEBFBFF000906EA
ProcessorType                           : 3
PSComputerName                          : R09872
Revision                                :
Role                                    : CPU
SecondLevelAddressTranslationExtensions : True
SerialNumber                            :
SocketDesignation                       : U3E1
Status                                  : OK
StatusInfo                              : 3
Stepping                                :
SystemCreationClassName                 : Win32_ComputerSystem
SystemName                              : R09872
ThreadCount                             : 12
UniqueId                                :
UpgradeMethod                           : 1
Version                                 :
VirtualizationFirmwareEnabled           : True
VMMonitorModeExtensions                 : True
VoltageCaps                             :
#>
# 硬盘信息 存在多块
Get-WMIObject -Class Win32_DiskDrive
Availability                :
BytesPerSector              : 512
Capabilities                : {3, 4}
CapabilityDescriptions      : {Random Access, Supports Writing}
Caption                     : SanDisk SSD PLUS 120GB
CompressionMethod           :
ConfigManagerErrorCode      : 0
ConfigManagerUserConfig     : False
CreationClassName           : Win32_DiskDrive
DefaultBlockSize            :
Description                 : 磁盘驱动器
DeviceID                    : \\.\PHYSICALDRIVE1
ErrorCleared                :
ErrorDescription            :
ErrorMethodology            :
FirmwareRevision            : UE4500RL
Index                       : 1
InstallDate                 :
InterfaceType               : SCSI
LastErrorCode               :
Manufacturer                : (标准磁盘驱动器)
MaxBlockSize                :
MaxMediaSize                :
MediaLoaded                 : True
MediaType                   : Fixed hard disk media
MinBlockSize                :
Model                       : SanDisk SSD PLUS 120GB
Name                        : \\.\PHYSICALDRIVE1
NeedsCleaning               :
NumberOfMediaSupported      :
Partitions                  : 1
PNPDeviceID                 : SCSI\DISK&VEN_SANDISK&PROD_SSD\4&180A7151&0&000200
PowerManagementCapabilities :
PowerManagementSupported    :
PSComputerName              : R09872
SCSIBus                     : 0
SCSILogicalUnit             : 0
SCSIPort                    : 0
SCSITargetId                : 2
SectorsPerTrack             : 63
SerialNumber                : 1835B0806210
Signature                   :
Size                        : 120039736320
Status                      : OK
StatusInfo                  :
SystemCreationClassName     : Win32_ComputerSystem
SystemName                  : R09872
TotalCylinders              : 14594
TotalHeads                  : 255
TotalSectors                : 234452610
TotalTracks                 : 3721470
TracksPerCylinder           : 255

# 操作系统信息		CIM_OperatingSystem
Get-WMIObject -Class Win32_OperatingSystem
<#
BootDevice                                : \Device\HarddiskVolume2
BuildNumber                               : 18363
BuildType                                 : Multiprocessor Free
Caption                                   : Microsoft Windows 10 专业版
CodeSet                                   : 936
CountryCode                               : 86
CreationClassName                         : Win32_OperatingSystem
CSCreationClassName                       : Win32_ComputerSystem
CSDVersion                                :
CSName                                    : R09872
CurrentTimeZone                           : 480
DataExecutionPrevention_32BitApplications : True
DataExecutionPrevention_Available         : True
DataExecutionPrevention_Drivers           : True
DataExecutionPrevention_SupportPolicy     : 2
Debug                                     : False
Description                               :
Distributed                               : False
EncryptionLevel                           : 256
ForegroundApplicationBoost                : 2
FreePhysicalMemory                        : 7245268
FreeSpaceInPagingFiles                    : 4413728
FreeVirtualMemory                         : 6258060
InstallDate                               : 20200224113745.000000+480
LargeSystemCache                          :
LastBootUpTime                            : 20200224115724.234553+480
LocalDateTime                             : 20200306174527.096000+480
Locale                                    : 0804
Manufacturer                              : Microsoft Corporation
MaxNumberOfProcesses                      : 4294967295
MaxProcessMemorySize                      : 137438953344
MUILanguages                              : {zh-CN, en-US}
Name                                      : Microsoft Windows 10 专业版|C:\WINDOWS|\Device\Harddisk0\Partition3
NumberOfLicensedUsers                     :
NumberOfProcesses                         : 263
NumberOfUsers                             : 2
OperatingSystemSKU                        : 48
Organization                              :
OSArchitecture                            : 64 位
OSLanguage                                : 2052
OSProductSuite                            : 256
OSType                                    : 18
OtherTypeDescription                      :
PAEEnabled                                :
PlusProductID                             :
PlusVersionNumber                         :
PortableOperatingSystem                   : False
Primary                                   : True
ProductType                               : 1
PSComputerName                            : R09872
RegisteredUser                            :
SerialNumber                              : 00330-55503-50586-AAOEM
ServicePackMajorVersion                   : 0
ServicePackMinorVersion                   : 0
SizeStoredInPagingFiles                   : 4845072
Status                                    : OK
SuiteMask                                 : 272
SystemDevice                              : \Device\HarddiskVolume4
SystemDirectory                           : C:\WINDOWS\system32
SystemDrive                               : C:
TotalSwapSpaceSize                        :
TotalVirtualMemorySize                    : 21460876
TotalVisibleMemorySize                    : 16615804
Version                                   : 10.0.18363
WindowsDirectory                          : C:\WINDOWS
#>


# ServicePack 版本
Get-CimInstance -ClassName Win32_OperatingSystem | select ServicePackMajorVersion, ServicePackMinorVersion

# 操作系统的安装日期
Get-CimInstance -ClassName Win32_OperatingSystem | select Installdate
 
# Windows 版本
Get-CimInstance -ClassName Win32_OperatingSystem | select Caption, Version
 
# windows 目录
Get-CimInstance -ClassName Win32_OperatingSystem | select WindowsDirectory




Function getSoftware($softwareName){
 $reg=’HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall’,’HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall’,’HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall’
 Foreach ($re in $reg){
  ls $re|where{
   $_.GetValue( 'displayname') -ne $null -and $_.GetValue( 'displayname') -like $softwareName 
  }
 }
}


$arr=@();Get-WMIObject -Class Win32_OperatingSystem |Get-Member -MemberType Properties|Sort name|%{If(!$_.name.StartsWith('_')){$arr+=$_.name}}
Get-WMIObject -Class Win32_OperatingSystem|select $arr

Function getAllProtites($script){
	$arr=@();$obj=Invoke-Expression $script; $obj|Get-Member -MemberType Properties|Sort name|%{If(!$_.name.StartsWith('_')){$arr+=$_.name}}
	$obj|select $arr
}
