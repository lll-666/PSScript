If($web -eq $null){$web=New-Object System.Net.WebClient;$web.Encoding=[System.Text.Encoding]::UTF8;}

Function Print-Exception([String]$command){
	Return "execute Command [$command] Exception,The Exception is $($error[0])"
}

Function Ret-Success([String] $business){
	Return "$business%%SMP:success"
}

Function Is-Success($Ret){
	If($Ret -ne $null -And ($Ret|Select -Last 1).EndsWith('%%SMP:success')){Return $True}
	Return $False
}

Function Download-File([String]$src,[String]$des,[bool]$isReplace=$false){
	If([String]::IsNullOrEmpty($src)){Return "BusinessException:Source file does not exist"}
	If([String]::IsNullOrEmpty($des)){Return "BusinessException:Destination address cannot be empty"}
	If(Test-Path $des){
		while (Test-FileLocked $des){
			sleep 1;
			If($i++ -gt 1){Return "File [$des] is in use"}
		}
		$file=ls $des;
		If(Test-Path ($file.DirectoryName+"/"+$file.basename+"_end")){Return Ret-Success "Download-File:No Need Operator"}
	}
	Try{
		$web=New-Object System.Net.WebClient;
		$web.Encoding=[System.Text.Encoding]::UTF8;
		$web.DownloadFile("$src", "$des");
		$file=(ls $des);
		$endFile=$file.basename+"_end";
		New-Item -Path $file.DirectoryName -Name $endFile -ItemType "file" |Out-Null
		If(!(Test-Path $des) -or (Get-Content "$des" -totalcount 1) -eq $null){Return "BusinessException:The downloaded file does not exist or the content is empty"}
	}Catch{Return Print-Exception "$web.DownloadFile($src,$des)"}
	Return Ret-Success "Download-File"
}

#用于写Log日志
Function WriteLog($msg){(Get-Date).ToString()+" >> $msg">>$logFile}

Function Check-Password($pc,$userName,$passes,[int]$startIndex,[int]$endIndex){
	WriteLog "当前检测账号为{$userName},检测的密码段为{$startIndex-$endIndex}"
	If($endIndex -ge $passes.length){$endIndex=$passes.length-1}
	Foreach($index in $startIndex..$endIndex){
		$pass=$passes[$index];
		$isValid=$pc.ValidateCredentials($username,$pass);
		If(!$?){
			WriteLog "执行命令{$pc.ValidateCredentials($username,$pass)}异常,异常信息为{$($error[0])}"
			Return Update-Result -userName $username -pass $pass -status exception -startIndex $startIndex -endIndex $endIndex -lineIndex $index
		}
		If($isValid){
			Return Update-Result -userName $username -pass $pass -status matched -startIndex $startIndex -endIndex $endIndex -lineIndex $index
		}
	}
	
	If($endIndex -ge ($passes.length-1)){
		Update-Result -userName $userName -status nomatched -startIndex $startIndex -endIndex $endIndex;
	}Else{
		Update-Result -userName $username -status detecting -startIndex ($endIndex+1) -endIndex ($endIndex+$interval)
		Check-Password -pc $pc -userName $username -passes $passes -startIndex ($endIndex+1) -endIndex ($endIndex+$interval)
	}
}

Function check($userName,$startIndex,$endIndex){
	If(!(Test-Path $pwdPath)){
		WriteLog "路径为{$pwdPath}的密码库不存在,正在下载密码库...";
		$down=Download-File $passAddr $pwdPath;
		WriteLog $down;
		If(!$down.EndsWith("%%SMP:success")){Return}
	}
	
	If($passes -eq $null){
		WriteLog "读取密码库信息"
		[String[]]$passes=[System.IO.File]::ReadAllLines($pwdPath);
		WriteLog "密码库的大小为$($passes.length)"
	}
	
	$flagFilePath=$dbPath+"/$userName"
	If(Test-Path $flagFilePath){
		If(Test-FileLocked $flagFilePath){
			Return WriteLog "标志文件{$flagFilePath}已锁定,本次不再处理";
		}Else{
			WriteLog "删除旧标志文件{$flagFilePath}";
			rm $flagFilePath;			
		}
	}
	
	WriteLog "新建标志文件{$flagFilePath}";
	New-Item $flagFilePath -ItemType "file"|Out-Null
	
	WriteLog "给标志文件{$flagFilePath}加锁";
	$os=[io.file]::Open($flagFilePath,"Open","Read","None")
	
	Check-Password -pc $pc -userName $userName -passes $passes -startIndex $startIndex -endIndex $endIndex
	
	WriteLog "给标志文件{$flagFilePath}释放锁";
	$os.close();
	
	WriteLog "删除标志文件{$flagFilePath}";
	rm $flagFilePath;
}

Function Test-FileLocked([string]$filePath) {
	try{[IO.File]::OpenWrite($filePath).close();$res=$false}catch{$res=$true}
	WriteLog "检测文件{$filePath}的锁状态为{$res}"
	Return $res;
}

Function Delete-Result($userName){
	WriteLog "开始删除账号{$userName}的检测结果"
	$res=New-Object System.Collections.ArrayList($null)
	Import-Csv $outPath|%{$null=$res.add($_)}
	$indexs=$res.count-1;
	Foreach($index in 0..$indexs){
		If($userName -eq $res[$index].userName){
			$ttt=$res.removeAt($index);
			$res|select userName,pass,status,lineIndex,startIndex,endIndex,date|Export-Csv $outPath;
			Return WriteLog "成功删除了账号{$userName}的检测结果"
		}
	}
	WriteLog "删除失败,无匹的账号{$userName}"
}

Function Update-Result($userName,$pass,$status,$startIndex,$endIndex,$lineIndex){
	WriteLog "开始更新账号{$userName}的检测结果"
	[PSObject[]]$res = Import-Csv $outPath
	$operateTime=(Get-Date).ToString();
	Foreach($re in $res){
		If($userName -eq $re.userName){
			If(![String]::IsNullOrEmpty($pass)){$re.pass=$pass}
			If(![String]::IsNullOrEmpty($status)){$re.status=$status}
			If(![String]::IsNullOrEmpty($startIndex)){$re.startIndex=$startIndex}
			If(![String]::IsNullOrEmpty($endIndex)){$re.endIndex=$endIndex}
			If(![String]::IsNullOrEmpty($lineIndex)){$re.lineIndex=$lineIndex}
			$re.lastModifiedTime=$operateTime;
			$exsit=$true;
			Break;
		}
	}
	If(!$exsit){$res+=New-Object PSObject -Property @{userName=$userName;pass=$pass;status=$status;lineIndex=$lineIndex;startIndex=$startIndex;endIndex=$endIndex;createTime=$operateTime;lastModifiedTime=$operateTime}}
	$res|select userName,pass,status,lineIndex,startIndex,endIndex,createTime,lastModifiedTime|Export-Csv $outPath;
	WriteLog "成功地更新账号{$userName}的检测结果"
}

Function Manager-Log($logFile,$capacity){
	If(!(Test-Path $logFile)){Return}
	#限制文件大小50M以内
	If($capacity -ge 50){$capacity=50}
	If((ls $logFile).length -ge $capacity*1024*1024){
		If(Test-Path "${logFile}.1"){
			rm -Force "${logFile}.1"
		}
		mv $logFile $logFile "${logFile}.1"
	}
}

Function Main{
	#该作用下的全局变量
	$interval=5000
	#单位M
	$capacity=3
	#单位min
	$expiresMin=3
	#密码地址
	$passAddr='http://172.17.8.218:9888'
	$passAddr+='/nodeManager/file/download/1-100W.TXT'
	#密码检测根目录
	$dbPath=$env:SystemDrive+"/Program Files/Ruijie Networks/passdb"
	#日志文件
	$logFile="$dbPath/log"
	#账号弱密码检测结果
	$pwdPath="$dbPath/pwdDb.csv"
	#清除日志
	If(!(Test-Path $logFile)){
		mkdir $dbPath -Force|Out-Null
		New-Item $logFile -ItemType "file"|Out-Null
		WriteLog "首次执行::初始化[密码库执行根目录]和[日志文件]完成"
	}
	Manager-Log $dbPath $capacity
	WriteLog '--------------------------------------------start---------------------------------------------'
	WriteLog "定时器执行目录{$dbPath}";
	WriteLog "定时器输出的日志文件{$logFile}"
	WriteLog '检测弱密码开始...';
	
	$accs=New-Object System.Collections.ArrayList($null);
	Get-WmiObject Win32_userACcount|?{$_.__SERVER -eq $_.domain -And $_.name -ne $env:username -And $_.status -eq 'ok'}|%{$null=$accs.add($_.name)}
	
	WriteLog "需要检测系统账号列表为{$accs}";
	If($accs.count -eq 0){Return}
	
	$outPath="${dbPath}/res.csv"
	If(!(Test-Path $outPath)){New-Item $outPath -ItemType "file"|Out-Null}
	
	[System.Reflection.Assembly]::LoadWithPartialName('System.DirectoryServices.AccountManagement')|Out-Null
	WriteLog "已加载了System.DirectoryServices.AccountManagement模块";
	$pc=New-Object -TypeName System.DirectoryServices.AccountManagement.PrincipalContext 'Machine',$env:COMPUTERNAME
	
	WriteLog "读取旧的密码检测结果"
	$tmps=Import-Csv $outPath
	Foreach($tmp in $tmps){
		$userName=$tmp.userName
		If($accs -contains $userName){
			WriteLog "从要检测密码的账号列表中去除已经检测过的账号{$userName}"
			$accs.remove($userName);
			If('detecting' -eq $tmp.status){
				check -userName $userName -startIndex $tmp.startIndex -endIndex $tmp.endIndex
			}Else{
				If(([datetime]$tmp.lastModifiedTime).compareTo((Get-Date).AddMinutes(-($expiresMin))) -eq -1){
					WriteLog "账号{$userName}的检测结果已失效"
					Delete-Result $tmp.userName
					check -userName $userName -startIndex 0 -endIndex $interval
				}
				WriteLog "已完成的检测账号{$userName},不再重复检测"
			}
		}Else{
			WriteLog "删除系统不存在账号{$userName}的检测结果"
			Delete-Result $tmp.userName
		}
	}
	
	Foreach($acc in $accs){
		WriteLog "首次进行密码检测的账号{$acc}"
		If($pc.ValidateCredentials($acc,'')){
			Return Update-Result -userName $acc -status matched
		}
		Update-Result -userName $acc -status detecting -startIndex 0 -endIndex $interval
		check -userName $acc  -startIndex 0 -endIndex $interval
	}
	WriteLog '--------------------------------------------end---------------------------------------------'
}
Main

<#SCHTASKS /Create /tn checkPassword /sc MINUTE /MO 120 /tr C:\Windows\System32\CheckWeakPassword.bat /st 16:01
#任务名称:checkPassword 频次单位:分钟 120分钟 执行任务:C:\Windows\System32\CheckWeakPassword.bat 开始时间:16:01
schtasks /create  /tn checkPassword /sc MINUTE /MO 30 /tr C:\Users\Administrator\Desktop\CheckWeakPassword.bat /st 17:10
SCHTASKS /Delete /TN checkPassword /F
schtasks /query /TN checkPassword
Get-Process powershell|%{If($_.id -ne $pid){taskkill -pid $_.id -f}}

Get-ScheduledJob -Name shiyan
Unregister-ScheduledJob -Name shiyan
Register-ScheduledJob -Name shiyan -ScriptBlock {Invoke-Expression (New-Object System.Net.WebClient).DownloadString('C:\Users\Administrator\Desktop\Job.ps1')} -RunEvery '17:30:00'

$O = New-ScheduledJobOption -WakeToRun -StartIfIdle -MultipleInstancePolicy Queue
$T = New-JobTrigger -Weekly -At "9:00 PM" -DaysOfWeek Monday -WeeksInterval 2
$path = "C:\Users\Administrator\Desktop\Job.ps1"
Register-ScheduledJob -Name "Check-WeakPass" -FilePath $path -ScheduledJobOption $O -Trigger $T

$T = @{
  Frequency="Weekly"
  At="9:00PM"
  DaysOfWeek="Monday"
  Interval=2
}
$O = @{
  WakeToRun=$true
  StartIfNotIdle=$false
  MultipleInstancePolicy="Queue"
}
Register-ScheduledJob -Trigger $T -ScheduledJobOption $O -Name "Check-WeakPass" -FilePath $path
#>