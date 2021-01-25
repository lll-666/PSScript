
$sa = new-object -com Shell.Application
$sa.Namespace(17).items() |
ForEach {
	If ($_.Type -match '移动电话'){
		$_.InvokeVerb("Eject")
	}
}
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($sa)



