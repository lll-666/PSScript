#get-disk | where BusType -eq USB | get-partition | get-volume
Function Get-Disk(){
	$Array=@()
	$USBDrives = Get-WmiObject win32_DiskDrive|?{Get-WmiObject win32_DiskDrive|?{$_.Partitions -eq 1 -And ($_.InterfaceType -eq 'USB' -Or $_.MediaType -like 'External*')}}
	If($USBDrives -eq $null){Return $Array}
	$DriveToPartitionMappings = Get-WmiObject Win32_DiskDriveToDiskPartition|Select Antecedent,Dependent
	$LogicalDiskMappings = Get-WmiObject Win32_LogicalDiskToPartition
	$LogicalDisks = Get-WmiObject Win32_LogicalDisk
	Foreach ($Device in $USBDrives){
		$DiskPhysicalDrive = "PHYSICALDRIVE" + "$($Device.Index)"
		$DriveToPartition = $DriveToPartitionMappings | ? {$_.Antecedent -match "$DiskPhysicalDrive"}
		If($DriveToPartition -eq $null){Continue}
		$PartitionToLogicalDisk = $LogicalDiskMappings | ? {$_.Antecedent -eq "$($DriveToPartition.Dependent)"}
		If($DriveToPartition -eq $null){Continue}
		$LogicalDisk = $LogicalDisks | ? {($_.Path).Path -eq ($PartitionToLogicalDisk.Dependent)}
		If($DriveToPartition -ne $null){$Array += $LogicalDisk.DeviceID}
	}
	Return $Array
}