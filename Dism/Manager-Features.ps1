#以管理员身份运行CMD
Dism /online /Get-Features
#获取所有组件名称,比如IIS,.Net等
#举例，启用或关闭 SMB 1.0/CIFS 文件共享支持
Dism /online /Enable-Feature /FeatureName:SMB1Protocol
Dism /online /Disable-Feature /FeatureName:SMB1Protocol