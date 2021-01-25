$a = Add-Type -memberDefinition @"
[DllImport("winmm.dll", CharSet = CharSet.Ansi)]
public static extern int mciSendStringA(
	string lpstrCommand,
	string lpstrReturnString,
	int uReturnLength,
	IntPtr hwndCallback);
"@ -passthru -name mciSendString
#$a::mciSendStringA('set cdaudio door open', $null, 0,0); # 打开光驱
$a::mciSendStringA('set cdaudio door closed', $null, 0,0)# 关闭光驱