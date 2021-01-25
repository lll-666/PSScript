Function Get-FireWallState{
	param(
		[ValidateSet('domainprofile','privateprofile','publicprofile')][String]$profile
	);
	$contents =(netsh advfirewall show $profile state)|Select -Skip 2 -First 2;
	$match=@((UnicodeToChinese '\u542f\u7528'),(UnicodeToChinese '\u6253\u5f00'),'on','open','enable');
	$discriminate=@((UnicodeToChinese '\u72b6\u6001'),'state')
	Foreach($content In $contents){
		$content=$content.ToLower();
		If(Contain $content $discriminate){
			Return Contain $content $match
		}
	}
}
Function Contain([String] $source,[Object[]] $elements){
	Foreach($element In $elements){
		If($source.Contains($element)){
			Return $true;
		}
	}
	$False
}