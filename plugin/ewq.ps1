function Invoke-TimeOutCommand([int]$Timeout,[string]$ScriptBlock){
   $job = Start-Job -ScriptBlock {$ScriptBlock}
   $null=$job | Wait-Job -Timeout $Timeout
   if($job.State -ne 'Completed'){
        $null=$job | Stop-Job | Remove-Job
        return 'timeout'
   }else{
		return Receive-Job $job
   }
}

Function Invoke-TimeOutCommand([int]$Timeout,[string]$script){$job = Start-Job -ScriptBlock {$script};$job|Wait-Job -Timeout $Timeout;if($job.State -ne 'Completed'){$job|Stop-Job|Remove-Job  return 'timeout'}else{return $job | Receive-Job}}