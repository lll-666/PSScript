$rsp=[RunspaceFactory]::CreateRunspacePool(1,1)
$rsp.Open()


$jobs=@()
$psl = [Powershell]::Create()
$job = $psl.AddScript({
	$r1=$args[0]
	$r2=$args[1]
	$r3=$args[2]
	
	
	
	$r1>>'C:\Users\Administrator\Desktop\tmpp';
	$r3>>'C:\Users\Administrator\Desktop\tmpp';
	$r2>>'C:\Users\Administrator\Desktop\tmpp'
	write-host 'fsdfsfsfds'
	}).AddArgument(@('ree','ewq','mmm'))
$job.RunspacePool = $rsp
$Jobs += New-Object PSObject -Property @{
  Server = $_
  Pipe = $Job
  Result = $Job.BeginInvoke()
}

Write-Host $("add task... " + $job.InstanceId)

Do{
   Write-Host "." -NoNewline
   Start-Sleep -Seconds 1
}While($Jobs.Result.IsCompleted -contains $false)
Write-Host "All jobs completed!"