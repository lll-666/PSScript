Function Black-SoftwareArr($blackList){
	$suc=0
	$logs=$null
	$blackList|ConvertFrom-Csv|Foreach{
		$ret=Black-Software $_.hostUrl $_.softwareName $_.softwareVersion ('True' -eq $_.isAuto) $_.processName $_.serviceName;$logs+="<<$_ :"+$ret+'>>';
		If(Is-Success $ret){$suc+=1}
	}
	Return ConvertToJson (New-Object PSObject -Property @{success=$suc;sum=$blackList.length-1;logs=$logs})
}