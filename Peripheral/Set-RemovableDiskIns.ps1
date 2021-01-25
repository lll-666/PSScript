#计算机\HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer
#隐藏所有光盘和软盘
Function Set-RemovableDiskIns($status){
	Check-OperateStatus $status
	
	#内核版本低于5,跳过
	If($PSVersionTable.BuildVersion.Major -le 5){Return}
	
	#ps5.0以上版本
	If($PSVersionTable.PSVersion.Major -ge 5){
		Set-RemovableDiskInsForPs5 $status -ErrorAction SilentlyContinue
	}

	#获取设备实体
	$RemovableDisk=Get-RemovableDiskIns
	If($RemovableDisk -eq $null -Or $RemovableDisk.count -eq 0){Return "There is no removable disk connected to the system %%SMP:success"}
	#启用或禁用设备实体
	Foreach($rem In $RemovableDisk){
		gwmi Win32_Volume|?{$_.DriveLetter -And $_.DriveLetter.substring(0,1) -eq $rem}|%{
			If('Enable' -eq $status){
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
}