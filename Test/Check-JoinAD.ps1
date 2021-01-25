$Username="administrator"
$Password="Ewq@54321"
$pass=ConvertTo-SecureString -AsPlainText $password -Force
$Cred=New-Object System.Management.Automation.PSCredential -ArgumentList $Username,$pass
Invoke-Command -ComputerName 192.168.54.252 -ScriptBlock {

Function Check-JoinAD(){
	$IsJoinAD=(Get-WmiObject Win32_ComputerSystem).PartOfDomain
	If($IsJoinAD){
		"{`"isSuccess`":`"true`"}"
	}else{
		"{`"isSuccess`":`"false`"}"
	}
};Check-JoinAD

} -credential $Cred
