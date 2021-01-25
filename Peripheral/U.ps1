# DriveType
# 2: USB Disk
# 3: HDD
# 5: ODD
 
$driverList=@{}  # HashTable  Key-Value
$driveType=@{2="USB_Disk";3="HDD";5="ODD"}   # HashTable  Key-Value
$ErrorActionPreference= 'silentlycontinue'   # 不显示错误, global variable

Function Get_DiskChange(){
    $Device_Logical=Get-WmiObject -Class Win32_LogicalDisk
    $Device_Logical_num = $Device_Logical.Length
    $Device_Physical =  Get-WmiObject -Class Win32_DiskDrive 
	<#
    $Device_Physical_num = $Device_Physical.Length    
	
    while($Device_Logical_num -eq (Get-WmiObject -Class Win32_LogicalDisk).Length){   
        Start-Sleep -s 1  
        #Listen  Disk Change
    }
	#>
    $Now_Time=Get-Date -Format "yyyy/MM/dd HH:mm:ss"
    $Dev_Change=Get-WmiObject -Class Win32_LogicalDisk  # 获取逻辑分区
    $com_Dev=Compare-Object $Device_Logical $Dev_Change  #比较两次差异
    $Disk_Change=$com_Dev.InputObject
    $diskName=$Disk_Change.DeviceID[0]
    
    $DevPhy_Change = Get-WmiObject -Class Win32_DiskDrive  #获取物理存储设备
    $com_DevPhy=Compare-Object $Device_Physical $DevPhy_Change  #比较差异
    $DiskPhy_Change=$com_DevPhy.InputObject 
    $DiskPhy_Model=$DiskPhy_Change.Model  #eg. Model      : USB DISK 3.0 USB Device
    $par="\d\.\d"    # 正则匹配  数字.数字  eg 3.0
    
    if ($DiskPhy_Model -match $par) {
        $DiskPhy_Model=$matches[0]   # 匹配到就赋值给$DiskPhy_Model
    }
    
    $DiskPhy_Size=[int]($DiskPhy_Change.Size /1000/1000/1000)   #转化为GB
    $type_num=$Disk_Change.DriveType
    $type=$driveType[[int]$type_num]
  
    if($Device_Logical_num -le (Get-WmiObject -Class Win32_LogicalDisk).Length){
        return ("Add_Device",$diskName,$type,$DiskPhy_Model,$DiskPhy_Size,$Now_Time)
    }elseif($Device_Logical_num -gt (Get-WmiObject -Class Win32_LogicalDisk).Length){
        return ("Remove Device",$diskName,$type,$DiskPhy_Model,$DiskPhy_Size,$Now_Time)
    }
}


Function DetectUSB(){
    echo "**********************  Listening  **********************"
    echo " "
    $a=Get_DiskChange
    echo "USB Device Information"
    echo " "
    "   time:          "+$a[5]
    "   Option:        "+$a[0]
    "   Volume label:  "+$a[1]
    "   Drive Type:    "+$a[2]
    "   Model:         "+$a[3]
    "   Total Size:    "+$a[4]+"GB"
    echo " "
    #函数中的所有输出 都在$a 中
    # for($i=0;$i -le $a.Length;$i++){
        # $i.ToString() +":" +$a[$i]
    # }


    if ($a[0] -eq "Add_Device"){ 
        # &执行命令
        & ($a[1].ToString()+":")  # 进入盘符
        $CheckDisk = chkdsk #执行CHKDSK
        # $CheckDisk 
        foreach ($i in $CheckDisk){
            if ($i -eq "Windows has scanned the file system and found no problems."){
				echo ""
				echo "CHKDSK pass"
				echo ""
				break
			} 
		}
    }   
}

while ($TRUE){
    # Powershell 中 布尔值 $TRUE $FALSE 和空值 $NULL
    DetectUSB
    # Start-Sleep -s 1  
}