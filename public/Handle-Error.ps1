Function Handle-Error{
	If($error){
		$t=$error.count-1;
		$rea=@();
		Foreach ($i in 0..$t){
			$rea+=$error[$i].toString()
		}
		$rea
	}Else{
		"Execution successful %%SMP:success"
	}
}