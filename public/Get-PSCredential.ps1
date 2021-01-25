Function Get-PSCredential([Parameter(Mandatory = $true)][String]$username,[Parameter(Mandatory = $true)][String]$password){
	Return New-Object System.Management.Automation.PSCredential($username,(ConvertTo-SecureString $Password -asPlainText -Force ))
}