Function Get-PSSession_($acc,$pass){
	If($session -and 'Opened' -eq $session.state){Remove-PSSession $session}
	Return New-PSSession $ip -Authentication Default -Credential (New-Object System.Management.Automation.PSCredential $acc,(ConvertTo-SecureString $pass -AsPlainText -Force)) -SessionOption (New-PSSessionOption -OpenTimeout 8) -ErrorAction SilentlyContinue
}
Function Reomve-PSSession_($session){
	If($session -and 'Opened' -eq $session.state){Remove-PSSession $session}
}

Function WriteLog($isSuccess,$command,$msg){
	New-Object PSObject -Property @{
		isSuccess=$isSuccess;
		command=$command;
		msg=($msg -join ';')
		date="$((Get-Date).tostring())"
	}|select date,isSuccess,command,msg|
		ConvertTo-Csv|
			select -Skip 2|
				Out-File "${upgraded}.csv" -Encoding UTF8 -Append
}

Function Plugin-ForUpdate($soure,$ip,$acc,$pass,$updateFlag,$srcNames){
	$session=Get-PSSession_ $acc $pass
	If(!$? -or ($session -eq $null)){Return WriteLog "false" "New-PSSession $ip -Authentication Default -Credential (getPSCredential $acc $pass)" "the exception is $($error[0])"}
	Plugin-ForUpdate_ $session $soure $updateFlag $srcNames
	Reomve-PSSession_ $session
}

Function Plugin-ForUpdate_($session,$soure,$updateFlag,$srcNames){
	$ret=Invoke-Command -Session $session{
		If([IntPtr]::size -eq 4){$pluginDir="$env:ProgramFiles\Ruijie Networks\"
		}Else{$pluginDir="${env:ProgramFiles(x86)}\Ruijie Networks\"}
		
		If(!(Test-Path $pluginDir)){
			$null=mkdir $pluginDir -Force
			Return @('uninstall',$pluginDir)
		}
		
		$updateFlag=Join-Path $pluginDir $args[0]
		If(Test-Path $updateFlag){Return @('upgraded',$updateFlag)}
		
		$null=ps NodeManager -ErrorAction SilentlyContinue|spps -Force -ErrorAction SilentlyContinue
		While($sv=gsv NodeService -ErrorAction SilentlyContinue){
			If($sv.status -eq 'Running'){
				spsv -Force -ErrorAction SilentlyContinue
				Sleep -Milliseconds 100;
				Continue
			}
		}
		
		$names=@("NodeManager*","uninstallPlugin","detect.dat","DuiLib.dll","Install.exe","Install.exe.manifest","libcrypto.dll","libeay32.dll","NodeService.exe","publickey.dat","skin.zip","ssleay32.dll","Uninstall.exe")
		$names|%{rm $_ -Force -ErrorAction SilentlyContinue}
		Return @('installed',$pluginDir)
	} -ArgumentList @($updateFlag) -ErrorAction SilentlyContinue
	If(!$?){Return WriteLog 'false' 'Invoke-Command for check' "the exception is $($error[0])"}

	$ret=[String[]]$ret
	If('upgraded' -eq $ret[0]){
		Return WriteLog 'true' "Invoke-Command" 'Has been upgraded'
	}
	cp -Path $soure -Destination $ret[1] -FromSession $session -ErrorAction SilentlyContinue
	If(!$?){Return WriteLog 'false' "cp" "$($ret[0]),the exception is $($error[0])"}
	$rs=Invoke-Command -Session $session{
		Foreach($name in $args[1]){cd $args[0];If(!(Test-Path $name)){Return 'Incomplete'}}
		$sv=gsv NodeService -ErrorAction SilentlyContinue
		If(!$? -or $sv -eq $null){
			$binpath="$($args[0])\NodeService.exe"
			If(Test-Path $binpath){$null=sc.exe create NodeService binpath= $binpath displayname= "NodeService" type= share}
		}
		Return 'Complete'
	} -ArgumentList @($ret[1],$srcNames)
	If(!$?){Return WriteLog 'false' "Invoke-Command for upgrade confirm" "the exception is $($error[0])"}
	
	If('Complete' -eq $rs){Return WriteLog 'true' "Invoke-Command" "Confirm Upgrade Complete"}
	Return WriteLog 'false' "Invoke-Command" "Confirm Incomplete upgrade"
}

$upgraded="upgraded-$(Get-Date -Format 'yyyyMMddHHmmss')"
$source='D:\SMP+\插件管理\合规插件\20200928\Plugin\'
$updateFlag='20210312'
$updatePath=Join-Path $source $updateFlag
If(!(Test-Path $updatePath)){$null=New-Item $updatePath}
$srcNames=ls $source|%{$_.name}
#1.数据源文件
$basePath=Join-Path $baseDir 天马账户属性修复结果-成功.csv
#2.加载数据源
$base = Import-Csv $basePath -Encoding utf8
$base|%{Plugin-ForUpdate -soure "${source}*" -ip '.' -acc 'hp' -pass $_.pass -updateFlag $updateFlag -srcNames $srcNames}