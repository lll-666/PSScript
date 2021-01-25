Invoke-Command -ComputerName 192.168.54.252 -ScriptBlock {


Function Set-PeripheralStatus{
	#3-启用,4-禁用
	param([int]$flag=4);
	#$ErrorActionPreference='SilentlyContinue';
	$registryPath="HKLM:\SYSTEM\CurrentControlSet\Services\USBSTOR";
	$key="Start";
	#未知（0），没有根目录（1），可移动磁盘（2），本地磁盘（3），网络驱动器（4），光盘（5），RAM磁盘（6）
	If($flag -eq 3){$operate='enable'}Else{$operate='disable'}
	If(!(Test-Path $registryPath)){
		$Null=md $registryPath -Force
	}
	$it=Get-ItemProperty -Path $registryPath -Name $key  -ErrorAction SilentlyContinue
	If($it -eq $null){
		Set-ItemProperty -Path $registryPath -Name $key -Value $flag;
	}
	If(!((Get-ItemProperty -Path $registryPath -Name $key).Start -eq $flag)){
		Set-ItemProperty -Path $registryPath -Name $key -Value $flag;
		If($error){Return $error[0].ToString()}
		$out="Successfully $operate disk through registry"
	}
	
	If($error){Return $error[0].ToString()}
	$Removeable=Get-WmiObject -Class  Win32_LogicalDisk -Filter "DriveType=2";
	If($Removeable -eq $null){
		Return "$out;The device is Already ${operate}d, There is no removable disk connected to the device %%SMP:success";
	}
	$sa=$Null;
	Foreach($drive In $Removeable){
		If($items -eq $Null){
			$sa=New-Object -ComObject Shell.Application; 
			$items=$sa.Namespace(17).items();
		}
		$items|%{
			If($_.Name -match $drive.$DeviceID){
				If($flag -eq 4){
					$_.InvokeVerb("Eject");
				}Else{
					$_.InvokeVerb("Allow");
				}
			}
		} 
	}
	If($sa -ne $Null){
		[System.Runtime.Interopservices.Marshal]::ReleaseComObject($sa); 
		Remove-Variable sa;
	}
	If($error){
		Handle-Error
	}Else{
		"$Out ;Successfully $operate the removable disk on the device %%SMP:success"
	}
};Function Unified-Return([Object[]]$msgs,[Parameter(Mandatory = $true)][String]$business){
	If($msgs -eq $Null -Or $msgs.count -eq 0){
		$isSuccess='false';
		$msg='No message returned';
	}Else{
		If(($msgs[-1]).EndsWith('%%SMP:success')){
			$isSuccess='true';
		}Else{
			$isSuccess='false';
		}
		$msg=($msgs -Join ';	').replace('\','/')
	}
	Return "{`"isSuccess`":`"$isSuccess`",`"msg`":`"$msg`",`"business`":`"$business`"}";
};Function Handle-Error{
	If($error){
		$t=$error.count-1;
		$rea=@();
		Foreach ($i in 0..$t){
			$rea+=$error[$i].toString()
		}
		$rea
	}Else{
		"Execution successful %%SMP:success"
	}
};Unified-Return (Set-PeripheralStatus 3) 'Set-PeripheralStatus'


} -credential $Cred
