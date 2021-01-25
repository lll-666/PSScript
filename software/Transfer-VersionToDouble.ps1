Function Transfer-VersionToDouble($version){
	$bs=$version.ToCharArray()
	$firstNum=$true
	$firstPoint=$true
	Foreach($bb in $bs){
		$b=[int]$bb;
		If($b -ge 48 -and $b -le 57){
			$des+=$bb
		}ElseIf($b -eq 46 -and $firstPoint){
			If($des){
				$des+=$bb;
				$firstPoint=$false
			}
		}
	}
	If($des){
		If($des[$des.length -1] -eq '.'){[int]($des.substring(0,$des.length -1))}else{[int]$des}
	}Else{0}
}