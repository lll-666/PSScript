
#参考链接
https://www.tenforums.com/tutorials/5918-how-turn-off-microsoft-defender-antivirus-windows-10-a.html

#注册表
HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender
DisableAntiSpyware DWORD
(delete) or 0 = On	1 = Off
 
#组策略
#(Windows 10 version 1909 and lower
Computer Configuration\Administrative Templates\Windows Components\Microsoft Defender Antivirus
#Windows 10 version 2004 and higher
Computer Configuration\Administrative Templates\Windows Components\Windows Defender Antivirus


