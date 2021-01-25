Function Check-JoinAD(){
	$IsJoinAD=(Get-WmiObject Win32_ComputerSystem).PartOfDomain
	If($IsJoinAD){
		"{`"isSuccess`":`"true`"}"
	}else{
		"{`"isSuccess`":`"false`"}"
	}
}