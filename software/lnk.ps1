function run(){
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    	[string[]]$name
    )
    function exec ([string]$name){
        $WshShell = New-Object -ComObject WScript.Shell
        $UserLnkFolder = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"
        $MachineLnkFolder = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs"
        $lnkList1 = Get-ChildItem -Path $UserLnkFolder -Filter *.lnk -Recurse
        $lnkList2 = Get-ChildItem -Path $MachineLnkFolder -Filter *.lnk -Recurse
        $lnkList = $lnkList1 + $lnkList2
        $programPathList = @()
        $programNameList = @()
        foreach ($lnk in $lnkList){
            $LnkFilePath = $Lnk.FullName
			$LnkShortcut = $WshShell.CreateShortcut($LnkFilePath)
            $LnkTargetPath = $LnkShortcut.TargetPath
            if(!([String]::IsNullOrEmpty($LnkTargetPath)) -And (Test-Path -Path $LnkTargetPath)){
				$CurrentProgramList = @()
				$CurrentProgramList += Get-Item $LnkTargetPath
				$CurrentProgramList += Get-Item $LnkFilePath
				if (!($name.Contains('*'))){
					$name = "*$name*"
				}
				foreach ($program in $CurrentProgramList){
					if($program.name -like $name -and $program -notin $programNameList){
						$programPathList += $LnkTargetPath
						$programNameList += $program.name
					}
				}
            }
        }
        
        $programPathList = $programPathList | Sort-Object -Unique
        if($programPathList -ne $null){
            if($programPathList -isnot [array]){
                Invoke-Item $programPathList
            }else{
                $selectedFile = @($programPathList | Out-GridView -Title 'Choose a program' -PassThru)
                if($selectedFile -ne $null){
                    Invoke-Item $selectedFile
                }
            }
        }else{
            Write-Output "The $name program dones't exist."
        }
    }
    if ($name -isnot [array]){
        exec $name
    }else{
        foreach ($i in $name){
            exec $i
        }
    }
}