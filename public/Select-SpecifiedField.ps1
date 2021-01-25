function Select-SpecifiedField($obj,$col){
	$obj|ForEach-Object{
		$retVal=1|Select-Object $col;
		$ob=$_;
		$col|ForEach-Object{
			$tmp=$ob.$_;
			if(![string]::IsNullOrEmpty($tmp)){
				if($tmp.gettype().name -eq 'string'){
					$retVal.$_=($tmp -replace [Regex]::UnEscape('\u0000'), '').Replace('\','/').Replace('"','')
				}elseif($tmp.gettype().name -eq 'int32'){
					$retVal.$_=$tmp
				}
			}
		};
		$retVal
	}
}