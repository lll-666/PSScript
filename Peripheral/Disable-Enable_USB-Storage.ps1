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

If($usb_State.Start -eq 4){
	Write-Host "Removable Storage and Network Services are disabled...nThis script will enable all Removable Storage and Network Services...n" ; 
	$e = (Read-Host "If you want to enable these services, Push E"); 
	If($e -eq "e"){
		Write-Host "Enabling USB Storage..."
		Set-ItemProperty  "$usb_Reg" -Name start -Value 3; 
		Start-Sleep -Seconds 1
		Write-Host "Enabling CD/DVD ROM..."
		Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\services\cdrom" -Name start -Value 1 ; 
		Write-Host "Enabling Card Readers..."
		Remove-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\RemovableStorageDevices" -Name Deny_All -Force -ErrorAction SilentlyContinue ; 
	}
}Else{
	Write-Host "Removable Storage and Network Services are Enabled...nThis script will disable all Removable Storage and Network Services...n" ; 
	$d = (Read-Host "If you want to disable these services, Push D");
	If($d -eq "d"){
		Write-Host "Disabling USB Storage..."
		Set-ItemProperty  "$usb_Reg" -Name start -Value 4;
		Start-Sleep -Seconds 1
		Write-Host "Disabling CD/DVD ROM..."
		Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\services\cdrom" -Name start -Value 4; 
		Write-Host "Disabling Card Readers..."
		New-Item "HKLM:\Software\Policies\Microsoft\Windows\RemovableStorageDevices" -Force -ErrorAction SilentlyContinue | Out-Null ; 
		New-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\RemovableStorageDevices" -Name Deny_All -Value 1 -PropertyType DWORD | Out-Null ; 
	}
}