$Array = @()
$USBDrives = Get-Disk | ? {$_.BusType -eq "USB"}
$DriveToPartitionMappings = Get-WmiObject Win32_DiskDriveToDiskPartition | Select Antecedent,Dependent
$LogicalDiskMappings = Get-WmiObject Win32_LogicalDiskToPartition
$LogicalDisks = Get-WmiObject Win32_LogicalDisk
Foreach ($Device in $USBDrives){
    $DiskPhysicalDrive = "PHYSICALDRIVE" + "$($Device.DiskNumber)"
    $DriveToPartition = $DriveToPartitionMappings | ? {$_.Antecedent -match "$DiskPhysicalDrive"}
    $PartitionToLogicalDisk = $LogicalDiskMappings | ? {$_.Antecedent -eq "$($DriveToPartition.Dependent)"}
    $LogicalDisk = $LogicalDisks | ? {($_.Path).Path -eq ($PartitionToLogicalDisk.Dependent)}
    $Hash = @{
        "Drive Letter" = $logicalDisk.DeviceID;
        "Disk Number" = $Device.DiskNumber;
        "Volunme Name" = $LogicalDisk.VolumeName;
        "Serial Number" = $Device.SerialNumber;
        "Size (MBs)" = [system.math]::Round(($LogicalDisk.Size / 1MB),1);
        "Free (MBs)" = [system.math]::Round(($LogicalDisk.FreeSpace / 1MB),1)
    }
    $Object = New-Object -TypeName PSObject -Property $Hash
    $Array += $Object
}
Return $Array