#串行执行
Measure-Command{
	$web=New-Object System.Net.WebClient
	$web.Encoding=[System.Text.Encoding]::UTF8
	$src='http://172.17.8.218:9888/nodeManager/file/download/temp?fileName=ip-guard.exe&dir=win/bit64'
	$des='C:\Users\Administrator\Desktop\tmp\ip-guard'
	foreach($i in 1..5){
		$web.DownloadFile("$src", "${des}$i")
	}
}

#并行执行
Measure-Command{
	$Throttle = 10 
	$RunspacePool=[RunspaceFactory]::CreateRunspacePool(2, $Throttle)
	$RunspacePool.Open()
	$Jobs = @()
	$ScriptBlock={
		param($i)
		$dir='C:\Users\Administrator\Desktop\tmp2'
		If(Test-Path $dir){$null=mkdir 'C:\Users\Administrator\Desktop\tmp2' -force}
		$i >> "$dir/test.txt"
 		sleep 1
		<#
		$web=New-Object System.Net.WebClient
		$web.Encoding=[System.Text.Encoding]::UTF8
		$src='http://172.17.8.218:9888/nodeManager/file/download/temp?fileName=ip-guard.exe&dir=win/bit64'
		$des='C:\Users\Administrator\Desktop\tmp1\ip-guard'
		$web.DownloadFile("$src", "${des}")
		#>
	}
	
	foreach($i in 1..5){
	   $Job = [powershell]::Create().AddScript($ScriptBlock).AddArgument($i)
	   $Job.RunspacePool = $RunspacePool
	   $Jobs += $Job.BeginInvoke()
	}
	
	Write-Host "Waiting.." -NoNewline
	Do{
	   Write-Host "." -NoNewline
	   Start-Sleep -Seconds 1
	}While($Jobs.IsCompleted -contains $false)
	Write-Host "All jobs completed!"
}



$session=New-PSSession 172.17.8.179 -Credential (New-Object System.Management.Automation.PSCredential('administrator',(ConvertTo-SecureString 'sfglsyb@163' -asPlainText -Force)))
Invoke-Command -Session $session {
	$Throttle = 10 
	$RunspacePool=[RunspaceFactory]::CreateRunspacePool(2, $Throttle)
	$RunspacePool.Open()
	$Jobs = @()
	$ScriptBlock={
		param($i)
		mkdir 'C:\Users\Administrator\Desktop\tmp1\temp'
		$web=New-Object System.Net.WebClient
		$web.Encoding=[System.Text.Encoding]::UTF8
		$src='http://172.17.8.218:9888/nodeManager/file/download/temp?fileName=ip-guard.exe&dir=win/bit64'
		$des='C:\Users\Administrator\Desktop\tmp1\ip-guard'
		$web.DownloadFile("$src", "${des}")
		'============================'
	}
	
	foreach($i in 1..1){
	   $Job = [powershell]::Create().AddScript($ScriptBlock).AddArgument($i)
	   $Job.RunspacePool = $RunspacePool
	   $Jobs += New-Object PSObject -Property @{
		  Server = $_
		  Pipe = $Job
		  Result = $Job.BeginInvoke()
	   }
	}
}
sleep 1
Remove-PSSession $session


rm C:\Users\Administrator\Desktop\tmp1\* -force
rm C:\Users\Administrator\Desktop\tmp\* -force


$ip='192.168.54.224'
$userName='Administrator'
$password='shyfzx@163'
Invoke-Command $ip {
Function Test-FileLocked([string]$FilePath) {
    try {[IO.File]::OpenWrite($FilePath).close();$false}catch{$true}
}
Function Check-DownloadFileIsComplete($FilePath){
	$isComplete=$false
	If(Test-Path $FilePath){
		$file=gi $FilePath
		$endFilePath=Join-Path $file.DirectoryName "$($file.basename)_end"
		$isComplete=Test-Path $endFilePath
	}
	Return New-Object PSObject -Property @{isComplete=$isComplete;endFilePath=$endFilePath;filePath=$FilePath}
}
Function Download-File([String]$src,[String]$des,[bool]$isReplace=$false){
	If([String]::IsNullOrEmpty($src)){Return "BusinessException:Source file does not exist"}
	If([String]::IsNullOrEmpty($des)){Return "BusinessException:Destination address cannot be empty"}
	If(!(Test-Path $des)){md $des}
	$des
	$res=Check-DownloadFileIsComplete $des
	If($res.isComplete){Return Ret-Success "Download-File:No Need Operator"}
	while (Test-FileLocked $des){
		sleep 1
		If($i++ -gt 1){Return "File [$des] is in use"}
	}
	Try{
		$web=New-Object System.Net.WebClient
		$web.Encoding=[System.Text.Encoding]::UTF8
		$web.DownloadFile("$src", "$des")
		If(!(Test-Path $des) -or (Get-Content "$des" -totalcount 1) -eq $null){Return "BusinessException:The downloaded file does not exist or the content is empty"}
		If([String]::IsNullOrEmpty($res.endFilePath)){$res=Check-DownloadFileIsComplete $des}
		New-Item -Path $res.endFilePath -ItemType "file"|Out-Null
	}Catch{Return Print-Exception "$web.DownloadFile($src,$des)"}
	Return Ret-Success "Download-File"
}

$src='http://172.17.8.218:9888/nodeManager/file/download/temp?fileName=ip-guard.exe&dir=win/bit64'
$des='C:\Users\Administrator\Desktop\tmp\ipguard'
Download-File $src $des
}-Credential (New-Object System.Management.Automation.PSCredential($userName,(ConvertTo-SecureString $Password -asPlainText -Force)))