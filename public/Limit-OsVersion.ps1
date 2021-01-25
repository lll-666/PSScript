$minLimitVersion = 6.2; 
$ver=Get-OsVersion
[Double]$systemVersion="$($ver.Major).$($ver.Minor)"
$msg="The current version is $systemVersion";
If($systemVersion -lt $minLimitVersion){
	"{`"isSuccess`":`"false`",`"msg`":`"$msg`"}" 
}Else{
	"{`"isSuccess`":`"true`",`"msg`":`"$msg`"}" 
}