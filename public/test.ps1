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