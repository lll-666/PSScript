# 执行异步（多线程）任务
function RunJobAsync {
    param($toexecute)
    $rsp = [RunspaceFactory]::CreateRunspacePool(1, 5)  #设置资源池中Runspace数量最少和最多
    $rsp.Open()
    $jobs = @()
    [int]$arg = 0
    # 遍历执行所有脚本
    foreach($s in $toexecute){
        $psl = [Powershell]::Create()
        $job = $psl.AddScript($s).AddArgument($arg++)    # 添加任务脚本和参数
        $job.RunspacePool = $rsp         
        Write-Host $("添加任务... " + $job.InstanceId)
        $jobs += New-Object PSObject -Property @{ 
            Job = $job
            PowerShell = $psl
            Result = $job.BeginInvoke()  # 异步执行任务脚本
        }
    }
    # 轮询等待任务完成
    do{ 
        Start-Sleep -seconds 1
        $cnt =($jobs | Where {$_.Result.IsCompleted -ne $true}).Count
        Write-Host ("运行中的任务数量: " + $cnt)
    }while($cnt -gt 0)
	
    foreach($r in $jobs) {    
        Write-Host ("任务结果: " + $r.Job.InstanceId) 
        $result = $r.Job.EndInvoke($r.Result)   # 取得异步执行结果
        # 注销 PowerShell 对象
        $r.PowerShell.Dispose()
        # 输出完成的任务脚本 
        #Write-Output ($result)               
        # 执行结果返回一个含有 Success 属性的对象
        if ($result.Success){ 
            Write-Host (" -> 任务执行成功 " + $result.Data + "，当前线程 " + $result.ThreadId) -ForegroundColor Green
        }else{ 
            Write-Host (" -> 任务执行失败 " + $result.Data + "，当前线程 " + $result.ThreadId) -ForegroundColor Red
        }
    }
}