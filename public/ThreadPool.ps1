#使用线程池
$RunspacePool=[RunspaceFactory]::CreateRunspacePool(2, 10)
$RunspacePool.Open()
$Jobs = @()
$ScriptBlock={
	param($i)
	$dir='C:\Users\Administrator\Desktop\tmp2'
	If(!(Test-Path $dir)){$null=mkdir 'C:\Users\Administrator\Desktop\tmp2' -force}
	"====$i====">>"$dir/test.txt"
}

Foreach($i in 1..5){
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
$RunspacePool.Close()
--------------------------------------------------------------------------------------
#不使用线程池
$Jobs=@()
Foreach($i in 1..5){
   $Job=[powershell]::Create().AddScript({Param($i);$i}).AddArgument($i)
   $Jobs+=$Job.BeginInvoke()
}
Write-Host "Waiting.." -NoNewline
Do{
   Write-Host "." -NoNewline
   Start-Sleep -Seconds 1
}While($Jobs.IsCompleted -contains $false)
Write-Host "All jobs completed!"

--------------------------------------------------------------------------------------
Param(
	[Parameter(Mandatory=$True)][int]$Index,
	[Parameter(Mandatory=$True)][String]$verifiedAccount,
	[Parameter(Mandatory=$True)][String[]]$passes
)
[powershell]::Create().AddScript({
	Param($arr)
	$ipMacList=Import-Csv -Path ./"ipMacList$($arr[0]).csv" -Encoding UTF8
	. .\Set-PasswordExpire.ps1
	Set-PasswordExpiresForIpMacList -ipMacList $ipMacList -verifiedAccount $arr[1] -passes $arr[2] -modifyAccount 'Nodemanager' -expire 'false'
}).AddArgument(0,'hp',@('shenmegui123','bunenggaosuni123')).BeginInvoke()




[powershell]::Create().AddScript({Param($i);"$i">>'C:\Users\Administrator\Desktop\tmp2\test.txt'}).AddArgument('11',4324,6546).BeginInvoke()