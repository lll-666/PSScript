$Username="administrator"
$Password="Ewq@54321"
$pass=ConvertTo-SecureString -AsPlainText $password -Force
$Cred=New-Object System.Management.Automation.PSCredential -ArgumentList $Username,$pass
Invoke-Command -ComputerName 192.168.54.29 -ScriptBlock {
netsh firewall set portopening TCP 445 enable
} -credential $Cred


<#

Function Dangerous-Port{
	param(
        [int] $port,
        [String] $protocol,
        [String] $action
    )
	If((Get-Service mpssvc).Status -ne 'Running'){Set-Service mpssvc -StartupType Automatic;Start-Service mpssvc;}
	If(![String]::IsNullOrEmpty($protocol)){$protocol=$protocol.ToLower()}
	$out=@()
	Foreach($tmp In @('allow','block')){
		$ruleName="SmpPlus-${protocol}-${port}-${tmp}";
		$res=netsh advfirewall firewall show rule name=$ruleName;
		If($res.Count -gt 3){
			If($tmp -eq $action){Return "Rule $ruleName already exists %%SMP:success"}
			$del=netsh advfirewall firewall delete rule name=$ruleName;
			$del|select -First 3|%{If(![String]::IsNullOrEmpty($_)){$rea+=$_}}
			If($del.Count -eq 2){Return  $out+="Failed to delete rule $ruleName,The reason is $rea" }Else{$out+="delete rule $ruleName succeeded"}
			Break;
		}
	}
	$ruleName="SmpPlus-${protocol}-${port}-${action}"
	$add=netsh advfirewall firewall add rule name=$ruleName profile=any dir=in protocol=$protocol localport=$port action=$action
	If($add.Count -eq 2 -And (($suffice=$add[0].ToLower().Trim()).Equals((UnicodeToChinese '\u786e\u5b9a\u3002')) -Or $suffice.Equals('ok.'))){
		$out+="Successfully added the rule named $ruleName %%SMP:success"
	}Else{
		$add|select -First 3|%{If(![String]::IsNullOrEmpty($_)){$rea+=$_}}
		$out+="Failed to add rule $ruleName,The reason is $rea"
	}
	$out
};Function UnicodeToChinese([String]$sourceStr){
	[regex]::Replace($sourceStr,'\\u[0-9-a-f]{4}',{param($v);[char][int]($v.Value.replace('\u','0x'))})
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
		$msg=($msgs -Join ';	').replace('\','/')
	}
	Return "{`"isSuccess`":`"$isSuccess`",`"msg`":`"$msg`",`"business`":`"$business`"}";
};Unified-Return (Dangerous-Port 445 tcp block) Dangerous-Port

#>