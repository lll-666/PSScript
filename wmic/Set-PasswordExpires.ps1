Function Set-PasswordExpires([String]$acc, [String]$expire){
	Function Set-PE($acc,$expire){
		$null=cmd /c "wmic.exe UserAccount Where Name=`"$acc`" Set PasswordExpires=`"$expire`""
		If(!$?){Return "false","The Exception is $error(0)"}
		$ret=cmd /c "wmic.exe UserAccount Where Name=`"$acc`" Get PasswordExpires"
		If($ret|?{$_ -like "*$expire*"}){Return "true","Property modified successfully"}
		Return "false",($ret -join ',')
	}
	
	$ret=cmd /c "wmic.exe UserAccount Where Name=`"$acc`" Get PasswordExpires"
	If(!$? -or ($ret -eq $null)){Return "false","the Exception is $error(0)"}
	Foreach($r in $ret){
		If('false' -eq $r.trim()){
			If('false' -eq $expire){Return "true","no need handle"}
			Return Set-PE $acc $expire
		}ElseIf('true' -eq $r.trim()){
			If('true' -eq $expire){Return "true","no need handle"}
			Return Set-PE $acc $expire
		}
	}
	Return "false","No Instance(s) Available"
}
Set-PasswordExpires 'nodemanager' 'false'