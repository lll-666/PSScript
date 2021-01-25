$Username="administrator"
$Password="Ewq@54321"
$pass=ConvertTo-SecureString -AsPlainText $password -Force
$Cred=New-Object System.Management.Automation.PSCredential -ArgumentList $Username,$pass
Invoke-Command -ComputerName 192.168.54.252 -ScriptBlock {

ls


} -credential $Cred
