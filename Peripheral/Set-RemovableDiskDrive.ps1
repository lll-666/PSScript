#REGSVR32 /U SHMEDIA.DLL 关掉所有移动硬盘上运行的文件和程序
#Password protected disable/enable for USB ports.
# SysTools USB Blocker
Function Set-RemovableDiskDrive($status){
	check-OperateStatus $status

	$osVer = (gwmi Win32_OperatingSystem).caption
	If($osVer -ne "Microsoft Windows 7 Enterprise"){
		If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")){   
			$arguments = "& '" + $myinvocation.mycommand.definition + "'"
			start powershell -Verb runAs -ArgumentList $arguments
			Break
		}
	}

	$usb_Reg="HKLM:\SYSTEM\CurrentControlSet\services\USBSTOR"
	If(!(Test-Path $usb_Reg)){$Null=md $usb_Reg -Force}
	$usb_State = gp $usb_Reg
	$cdDvd_reg="HKLM:\SYSTEM\CurrentControlSet\services\cdrom"
	If(!(Test-Path $cdDvd_reg)){$Null=md $cdDvd_reg -Force}
	$cdDvdRom_State = gp $cdDvd_reg
	$storageDev="HKLM:\Software\Policies\Microsoft\Windows\RemovableStorageDevices"
	$msg=@();
	If("Enable" -eq $status){
		$msg+="Enabling USB Storage..."
		If($usb_State.start -ne 3){sp $usb_Reg -Name start -Value 3}
		Sleep 1
		$msg+="Enabling CD/DVD ROM..."
		If($cdDvdRom_State.start -ne 1){sp $cdDvd_reg -Name start -Value 1}
		$msg+="Enabling Card Readers..."
		If(Test-Path $storageDev){rp $storageDev -Name Deny_All -Force -ErrorAction SilentlyContinue}
	}Else{
		$msg+="Disabling USB Storage..."
		If($usb_State.start -ne 4){sp $usb_Reg -Name start -Value 4}
		Sleep 1
		$msg+="Disabling CD/DVD ROM..."
		If($cdDvdRom_State.start -ne 4){sp $cdDvd_reg -Name start -Value 4}
		$msg+="Disabling Card Readers..."
		If(!(Test-Path $storageDev)){$Null=md $storageDev -Force -ErrorAction SilentlyContinue}
		$Null=sp $storageDev -Name Deny_All -Value 1 -Type DWORD
	}
	Return $msg
}