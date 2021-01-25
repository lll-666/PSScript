$Server=$env:computername
#server's CPU Mem Hardinfor
$cpu=Get-WMIObject –computername $Server win32_Processor
$mem=gwmi -ComputerName $Server win32_OperatingSystem
$Disks=gwmi –Computer: $Server win32_logicaldisk -filter "drivetype=3"
$Havecpu="{0:0.0} %" -f $cpu.LoadPercentage
$Allmem="{0:0.0} MB" -f ($mem.TotalVisibleMemorySize / 1KB)
$Freemem="{0:0.0} MB" -f ($mem.FreePhysicalMemory / 1KB)
$Permem="{0:0.0} %" -f ((($mem.TotalVisibleMemorySize-$mem.FreePhysicalMemory)/$mem.TotalVisibleMemorySize)*100)
Write-Host "COMPUTER:$Server"`r`n
# `r`n表示换行输出
Write-Host "CPU:$Havecpu"`r`n
Write-Host "Total Mem:$Allmem"
Write-Host "Free Mem:$Freemem"
Write-Host "Used Mem:$Permem"`r`n
$IpAdd=(Get-WmiObject -class win32_NetworkAdapterConfiguration -Filter 'ipenabled="true"').ipaddress[0]
Write-Host "Ipaddress:$IpAdd"`r`n