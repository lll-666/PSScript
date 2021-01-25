Function Unified-ReturnObj([Object[]]$msgs,[Parameter(Mandatory = $true)][String]$business,$obj){
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
	Return ConvertToJson (New-Object PSObject -Property @{isSuccess=$isSuccess;msg=$msg;business=$business;retObj=$retObj})
}