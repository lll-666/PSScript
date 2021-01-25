Filter Set-ProcessdF{
	Set-Processd -processName $_.processName -isRun ('true' -eq $_.isRun) -startFile $_.startFile -isClear ('true' -eq $_.isClear)
}