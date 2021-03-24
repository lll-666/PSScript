#以下3种方式等价
#方式一、
gwmi -namespace "root\cimv2\power" -class "Win32_PowerPlan" -Filter "IsActive=TRUE"
#方式二、
$Name=@{Namespace='root\cimv2\power';Class='Win32_PowerPlan'}
gwmi @Name -Filter "IsActive=TRUE"
#方式三、
$Name=@{Namespace='root\cimv2\power'}
gwmi @Name Win32_PowerPlan -Filter "IsActive=TRUE"


$Name=@{Namespace='root\cimv2\power'}
$Plan=@{Class='Win32_PowerPlan'}
$Lid='{5ca83367-6e45-459f-a27b-476b1d01c936}'
$ID=(gwmi @Name @Plan -Filter "IsActive=TRUE") -replace '.*(\{.*})"', '$1'
gwmi @Name Win32_PowerSettingDataIndex -Filter "InstanceId LIKE '%$Id\\%C\\$Lid'" |?{$_.instanceid.split("\")[2] -eq 'AC'} |
    Set-WmiInstance -Arguments @{ SettingIndexValue=0 }

powercfg
wmic
Get-NetAdapter 以太网|Get-NetAdapterPowerManagement