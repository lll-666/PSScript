Function Get-RemovableDiskIns{
	If($PSVersionTable.PSVersion.Major -ge 4){
		Return [Object[]](Get-Disk|? BusType -eq USB|Get-Partition|Get-Volume|%{If($_.DriveLetter){If($_.DriveLetter.getType().name -eq 'Char'){$_.DriveLetter}Else{$_.DriveLetter.substring(0,1)}}})
	}
	$Array=@()
	$USBDrives=gwmi win32_DiskDrive|?{ $_.InterfaceType -eq 'USB' }
	If($USBDrives -eq $null){Return $Array}
	$DriveToPartitionMappings=gwmi Win32_DiskDriveToDiskPartition|Select Antecedent,Dependent
	$LogicalDiskMappings=gwmi Win32_LogicalDiskToPartition
	$LogicalDisks=gwmi Win32_LogicalDisk
	Foreach ($Device in $USBDrives){
		$DiskPhysicalDrive="PHYSICALDRIVE" + "$($Device.Index)"
		$DriveToPartition=$DriveToPartitionMappings|? {$_.Antecedent -match "$DiskPhysicalDrive"}|%{$_.Dependent}
		If($DriveToPartition -eq $null){Continue}
		$PartitionToLogicalDisk=$LogicalDiskMappings|?{[Object[]]$DriveToPartition -contains $_.Antecedent}
		If($PartitionToLogicalDisk -eq $null){Continue}
		$LogicalDisk=$LogicalDisks|? {($_.Path).Path -eq ($PartitionToLogicalDisk.Dependent)}
		If($LogicalDisk -ne $null){$Array += $LogicalDisk.DeviceID.substring(0,1)}
	}
	Return $Array
}