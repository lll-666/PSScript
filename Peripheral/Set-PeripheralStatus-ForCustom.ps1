Function Set-PeripheralStatus($status){
        check-OperateStatus $status -ErrorAction SilentlyContinue
        If(!$?){Return Print-Exception "Set-PeripheralStatus"}
        
        #启用或禁用设备实体
        Set-RemovableDiskIns $status -ErrorAction SilentlyContinue
        
        #启用或禁用[驱动,服务]
        $msg=Set-RemovableDiskDrive $status -ErrorAction SilentlyContinue
        
        If(!$?){$msg}Else{"$msg %%SMP:success"}
};Function Check-OperateStatus($status){
        If(@('Disable','Enable') -notcontains $status ){throw "Illegal flag for peripheral operation. The correct flag is [Disable, Enable]"}
};Function Set-RemovableDiskIns($status){
        check-OperateStatus $status
        
        #内核版本低于5,跳过
        If($PSVersionTable.BuildVersion.Major -le 5){Return}
        
        #ps5.0以上版本
        If($PSVersionTable.PSVersion.Major -ge 5){
                Return Set-RemovableDiskInsForPs5 $status -ErrorAction SilentlyContinue
        }

        #获取设备实体
        $RemovableDisk=Get-RemovableDiskIns
        If($RemovableDisk -eq $null -Or $RemovableDisk.count -eq 0){Return "There is no removable disk connected to the system %%SMP:success"}
        #启用或禁用设备实体
        Foreach($rem In $RemovableDisk){
                gwmi Win32_Volume|？DriveLetter -And  DriveLetter.substring(0,1) -eq $rem|%{
                        If('Enable' -eq $flag){
                                #启用设备实体 TODO
                                $null=$_.AddMountPoint($diskCharacter)
                        }ELse{
                                #禁用设备实体
                                $_.DriveLetter=$null;
                                $null=$_.Put();
                                $null=$_.Dismount($false, $false)
                        }
                }
        }
};Function Set-RemovableDiskInsForPs5($status){
        check-OperateStatus $status
        If('disable' -eq $status){
                Get-PnpDevice|?{$_.Class -eq 'WPD'  -and $_.Status -eq 'ok'}|Disable-PnpDevice -Confirm:$false
        }Else{
                Get-PnpDevice|?{$_.Class -eq 'WPD'  -and $_.Status -eq 'error'}|Enable-PnpDevice -Confirm:$false
        }
};Function Get-RemovableDiskIns{
        If($PSVersionTable.PSVersion.Major -ge 4){
                Return [Object[]](Get-Disk|? BusType -eq USB|Get-Partition|Get-Volume|%{If($_.DriveLetter){$_.DriveLetter.substring(0,1)}})
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
};Function Set-RemovableDiskDrive($status){
        check-OperateStatus $status

        $osVer = (Get-WmiObject Win32_OperatingSystem).caption
        If($osVer -ne "Microsoft Windows 7 Enterprise"){
                If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")){   
                        $arguments = "& '" + $myinvocation.mycommand.definition + "'"
                        Start-Process powershell -Verb runAs -ArgumentList $arguments
                        Break
                }
        }

        $usb_Reg="HKLM:\SYSTEM\CurrentControlSet\services\USBSTOR"
        If(!(Test-Path $usb_Reg)){$Null=md $usb_Reg -Force}
        $usb_State = Get-ItemProperty $usb_Reg
        $cdDvd_reg="HKLM:\SYSTEM\CurrentControlSet\services\cdrom"
        If(!(Test-Path $cdDvd_reg)){$Null=md $cdDvd_reg -Force}
        $cdDvdRom_State = Get-ItemProperty $cdDvd_reg
        $storageDev="HKLM:\Software\Policies\Microsoft\Windows\RemovableStorageDevices"
        $msg=@();
        If("Enable" -eq $status){
                $msg+="Enabling USB Storage..."
                If($usb_State.start -ne 3){Set-ItemProperty $usb_Reg -Name start -Value 3}
                Start-Sleep -Seconds 1
                $msg+="Enabling CD/DVD ROM..."
                If($cdDvdRom_State.start -ne 1){Set-ItemProperty $cdDvd_reg -Name start -Value 1}
                $msg+="Enabling Card Readers..."
                Remove-ItemProperty $storageDev -Name Deny_All -Force -ErrorAction SilentlyContinue ; 
        }Else{
                $msg+="Disabling USB Storage..."
                If($usb_State.start -ne 4){Set-ItemProperty $usb_Reg -Name start -Value 4}
                Start-Sleep -Seconds 1
                $msg+="Disabling CD/DVD ROM..."
                If($cdDvdRom_State.start -ne 4){Set-ItemProperty $cdDvd_reg -Name start -Value 4}
                $msg+="Disabling Card Readers..."
                If(!(Test-Path $storageDev)){$Null=md $storageDev -Force -ErrorAction SilentlyContinue}
                $Null=New-ItemProperty $storageDev -Name Deny_All -Value 1 -PropertyType DWORD
        }
        Return $msg
};Set-PeripheralState 'enable'