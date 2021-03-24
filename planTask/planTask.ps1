#ps2.0
$csv=SCHTASKS /Query /FO CSV
$csvObj=ConvertFrom-Csv $csv
$taskNames=$csvObj|%{If($_.任务名.substring(1).indexOf('\') -eq -1 -and $_.任务名.startswith('\') -and $_.模式 -eq '就绪'){$_.任务名.substring(1)}}
$taskNames=New-Object -TypeName System.Collections.Generic.HashSet[string] -ArgumentList @([string[]]$taskNames,[System.StringComparer]::OrdinalIgnoreCase)
$taskNames|%{SCHTASKS /Change /DISABLE /TN S_}

#ps5.0
Get-ScheduledTask -TaskPath '\'|?{$_.state -eq 'Ready'}|Disable-ScheduledTask