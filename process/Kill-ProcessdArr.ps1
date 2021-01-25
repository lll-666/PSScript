Function Kill-ProcessdArr([Object[]]$operator){
	$ErrorActionPreference='SilentlyContinue';
	$msg=@();
	ConvertFrom-Csv $operator|Set-ProcessdF|%{$msg+=$_}
	If($error.count -eq 0){$isSuccess='true'}Else{$isSuccess='false';#$msg+=$error
	}
	$t=($msg -join ' ; ').replace('\','/');
	"{`"isSuccess`":`"$isSuccess`",`"msg`":`"$t`"}"
}