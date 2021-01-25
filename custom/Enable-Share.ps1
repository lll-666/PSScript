Function Enable-Share{
        Trap{Return Unified-Return $_.Exception.Message 'Enable-Share'}
        Unified-Return (Set-Share -enable) 'Enable-Share'
};Function Unified-Return([Object[]]$msgs,[Parameter(Mandatory = $true)][String]$business){
        If($msgs -eq $Null -Or $msgs.count -eq 0){
                $isSuccess='false';
                $msg='No message returned';
        }Else{
                If(($msgs[-1]).EndsWith('%%SMP:success')){
                        $isSuccess='true';
                }Else{
                        $isSuccess='false';
                }
                $msg=($msgs -Join ';    ').replace('\','/')
        }
        Return "{`"isSuccess`":`"$isSuccess`",`"msg`":`"$msg`",`"business`":`"$business`"}";
};Function Set-Share([Switch] $enable,[Switch] $disable){
        If(!$enable -and !$disable){throw "Please enter enable or disable"}
        $svcName='LanmanServer'
        $server=Get-Service $svcName -ErrorAction SilentlyContinue
        If($enable){
                If(!$server){throw "There is no shared service in the system , Please install this service first"}
                If($server.StartType -ne 'Automatic'){Set-Service $svcName -StartupType Automatic -ErrorAction SilentlyContinue}
                If($server.status -ne 'Running'){Start-Service $svcName}
        }Else{
                If(!$server){return "There is no shared service in the system , not need oprate"}
                If($server.StartType -ne 'Disabled'){Set-Service $svcName -StartupType Disabled -ErrorAction SilentlyContinue}
                If($server.status -ne 'Stopped'){Stop-Service $svcName}
        }
        Ret-Success
};Function Ret-Success([String] $business){
        Return "$business%%SMP:success"
};Enable-Share
