Function Check-OperateStatus($status){
	If(@('Disable','Enable') -notcontains $status ){throw "Illegal flag for peripheral operation. The correct flag is [Disable, Enable]"}
}