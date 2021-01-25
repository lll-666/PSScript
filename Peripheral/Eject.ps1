Function Get-USBDisk{
	$Array=@()
	$USBDrives = Get-WmiObject win32_DiskDrive|?{ $_.InterfaceType -eq 'USB' }
	If($USBDrives -eq $null){Return $Array}
	$DriveToPartitionMappings = Get-WmiObject Win32_DiskDriveToDiskPartition|Select Antecedent,Dependent
	$LogicalDiskMappings = Get-WmiObject Win32_LogicalDiskToPartition
	$LogicalDisks = Get-WmiObject Win32_LogicalDisk
	Foreach ($Device in $USBDrives){
		$DiskPhysicalDrive = "PHYSICALDRIVE" + "$($Device.Index)"
		$DriveToPartition = $DriveToPartitionMappings | ? {$_.Antecedent -match "$DiskPhysicalDrive"}|%{$_.Dependent}
		If($DriveToPartition -eq $null){Continue}
		$PartitionToLogicalDisk = $LogicalDiskMappings | where{[Object[]]$DriveToPartition -contains $_.Antecedent}
		If($PartitionToLogicalDisk -eq $null){Continue}
		$LogicalDisk = $LogicalDisks | ? {($_.Path).Path -eq ($PartitionToLogicalDisk.Dependent)}
		If($LogicalDisk -ne $null){$Array += $LogicalDisk.DeviceID.substring(0,1)}
	}
	Return $Array
}

If($PSVersionTable.PSVersion.Major -ge 4){
	$re = [Object[]](Get-Disk | where BusType -eq USB | Get-Partition | Get-Volume|%{If($_.DriveLetter){$_.DriveLetter}})
}Else{
	$re = Get-USBDisk
}
If($re -eq $null -Or $re.count -eq 0){Return}

Get-WmiObject Win32_Volume | where{$_.DriveLetter -And $re -contains $_.DriveLetter.substring(0,1)}|%{
	$_.DriveLetter=$null;
	$null=$_.Put();
	$null=$_.Dismount($false, $false)
}

#挂载
#(get-wmiobject -Class Win32_Volume|?{$_.label -eq 'U盘'}).AddMountPoint("G:")
<#
win32_DiskDrive
Win32_DiskPartition
Win32_DiskQuota
Win32_DiskDrivePhysicalMedia
Win32_DiskDriveToDiskPartition
Win32_MappedLogicalDisk
#>