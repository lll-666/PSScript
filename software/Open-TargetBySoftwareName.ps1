Function Open-TargetBySoftwareName(){
    param([Parameter(Mandatory=$true, ValueFromPipeline=$true)][string[]]$name)
	Function getLnk{
		$UserLnkFolder="$env:APPDATA\Microsoft\Windows\Start Menu\Programs"
        $MachineLnkFolder="$env:ProgramData\Microsoft\Windows\Start Menu\Programs"
        $lnkList1=ls -Path $UserLnkFolder -Filter "$name.lnk" -Recurse
		If($lnkList1 -ne $null){Return $lnkList1}
        Return ls -Path $MachineLnkFolder -Filter "$name.lnk" -Recurse
	}
    Function exec ([string]$name){
		$lnk=getLnk
		If($lnk -eq $null){Return}
		$LnkShortcut=(New-Object -ComObject WScript.Shell).CreateShortcut($lnk[0].FullName)
		If(Test-path $LnkShortcut.TargetPath){
			$targe=gi $LnkShortcut.TargetPath
			$process=ps $targe.basename -ErrorAction SilentlyContinue
			If($process -eq $process){ii $targe}
		}
    }
    exec $name
}