Function Disable-ServicedArr([Object[]]$operator){
	Set-ServicedArr $operator 'enable'
}