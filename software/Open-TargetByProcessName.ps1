Function Open-TargetByProcessName{
    param([Parameter(Mandatory=$true, ValueFromPipeline=$true)][string[]]$name)
	Function getLnk{
		$UserLnkFolder="$env:APPDATA\Microsoft\Windows\Start Menu\Programs"
        $MachineLnkFolder="$env:ProgramData\Microsoft\Windows\Start Menu\Programs"
        $lnkList1=ls -Path $UserLnkFolder -Filter "*.lnk" -Recurse
        $lnkList2=ls -Path $MachineLnkFolder -Filter "*.lnk" -Recurse
		Return ($lnkList1+$lnkList2)
	}
    Function exec ([string]$name){
		$lnks=getLnk
		If($lnks -eq $null){Return}
		Foreach($lnk in $lnks){
			$LnkShortcut=(New-Object -ComObject WScript.Shell).CreateShortcut($lnk.FullName)
			$TargetPath=$LnkShortcut.TargetPath 
			If(![String]::IsNullOrEmpty($TargetPath) -And (Test-path $TargetPath)){
				$targe=gi $TargetPath
				If($targe.basename -eq $name){
					If((ps $targe.basename -ErrorAction SilentlyContinue) -eq $null){Return ii $targe}
				}
			}
		}
    }
    exec $name
}