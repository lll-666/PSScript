Function Print-Exception([String]$command){
	Return "execute Command [$command] Exception,The Exception is $($error[0])"
}