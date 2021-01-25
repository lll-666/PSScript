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