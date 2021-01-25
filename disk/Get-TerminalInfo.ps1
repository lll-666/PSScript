Function Get-TerminalInfo{
	Function query($script){
		$arr=@();
		$obj=Invoke-Expression "Get-WMIObject $script"; 
		$obj|Get-Member -MemberType Properties|Sort name|%{If(!$_.name.StartsWith('_')){$arr+=$_.name}}
		$obj|Select $arr
	}
	@{	
		win32Bios=query Win32_BIOS;
		win32PhysicalMemoryList=query Win32_PhysicalMemory;
		win32Processor=query Win32_Processor;
		win32DiskDriveList=query Win32_DiskDrive;
		win32OperatingSystem=query Win32_OperatingSystem;
		win32LogicaldiskList=query Win32_Logicaldisk
	}
}