 #threads
 
#脚本块，对指定的计算机发送一个ICMP包测试，结果保存在一个对象里面
$ScriptBlock  = {
    Param([string] $Computer)
    $a=test-connection  -ComputerName  $Computer -Count 1 
    $RunResult=New-Object  PSObject -Property @{
       IPv4Adress=$a.ipv4address.IPAddressToString
       ComputerName=$Computer
    }
    Return  $RunResult
}

$RunspacePool=[RunspaceFactory]::CreateRunspacePool(1,2)
$RunspacePool.Open()
$Jobs=@()

'172.17.8.179'|%{
    $Job=[powershell]::Create().AddScript($ScriptBlock).AddArgument($_)
    $Job.RunspacePool=$RunspacePool
    $Jobs+=New-Object PSObject -Property @{
       Serve=$_
       Pipe=$Job
       Result=$Job.BeginInvoke()
    }
}
 
#循环输出等待的信息.... 直到所有的job都完成 
Write-Host "Waiting.."  -NoNewline
Do{
    Write-Host "." -NoNewline
    Start-Sleep -Seconds 1
}While($Jobs.Result.IsCompleted -contains $false)
Write-Host "All jobs completed!"
 
#输出结果 
$Results=@()
ForEach($Job in $Jobs){$Results+=$Job.Pipe.EndInvoke( $Job.Result)}
$Results