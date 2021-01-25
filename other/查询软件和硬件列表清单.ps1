<#
==========================================================================
' Date:2009/3/19
' Name: 查询软件和硬件列表清单
' Comment: blogs.itecn.net/smileruner
' Author:Smileruner
' www.overmcse.com
' 不支持Win2000及WinNT
'
' 3/19,添加了网卡过滤。
'==========================================================================
'on error resume Next
#>
const HKEY_LOCAL_MACHINE = &H80000002 
const UNINSTALL_ROOT = "Software\Microsoft\Windows\CurrentVersion\Uninstall"
const REG_SZ = 1


<#
'Set wshshell=wscript.createobject("wscript.shell")
' wshshell.run ("%comspec% /c regsvr32 /s scrrun.dll"),0,true
' wshshell.run ("%comspec% /c sc config  winmgmt start= auto"),0,true
' wshshell.run ("%comspec% /c net start winmgmt"),0
#>

strComputer = Inputbox("请输入要查询的计算机名称",,"")

If strComputer = "" then
	Wscript.Echo "未输入值或用户取消，查询退出。"
	Wscript.Quit
End If

Set objswbemlocator = createobject("wbemscripting.swbemlocator")
Set objswbemservices = objswbemlocator.connectserver(strComputer, "root\cimv2")
If Err.number <> 0 then
	Wscript.Echo "目标计算机无法连接。错误的计算机名，或目标计算机启用了防火墙，RPC服务不可用。"
	Err.number.clear
	Wscript.Quit
End If

#swbemservices.security_.impersonationleobjvel = 3

Set fso=createobject("scripting.filesystemobject")
FileDate = Replace(date(), "/", "-")
resoultfilepath= strComputer & FileDate & ".html"
Set resultFile= fso.createtextfile(resoultfilepath,,true)

HtmlWriteHead()
#Html文档开始

TableHead strComputer,"硬件清单"
#Html表格开始
#写入操作系统信息
OsWrite()
#写入主板信息
BoardWrite()
#写入CPU信息
CpuWrite()
#写入内存信息
MemoryWrite()
#写入硬盘信息
HarddiskWrite()
#写入CDROM信息
CdromWrite()
#写入显示卡信息
VideoWrite()
#写入网卡信息
NetcardWrite()
#Html表格结尾
TableEnd()
TableHead strComputer,"软件清单"
#Html表格开头
#写入软件信息
Softlist()
#Html表格结尾
TableEnd()
#Html文档结束
HtmlWriteEnd()

ResultFile.close 
Wscript.Echo "查询完成！"

#=========以下是函数列表==========


Function OsWrite() 
#函数,写入操作系统信息
	Set colOs =objswbemservices.execquery("select * from win32_operatingsystem",,48)
	For Each Ositem In colOs
			oscaption = Ositem.caption
			OsVersion = oscaption & Ositem.version
			WriteTable "操作系统",OsVersion
	Next
End Function 


Function BoardWrite()
#函数，写入主板信息
	Set colBoard = objswbemservices.execquery("select * from win32_baseboard")
	For Each Bditem In colBoard
			boardname = Bditem.product
			WriteTable "主板",boardname
	Next
End Function 


Function CpuWrite()
#函数，写入CPU信息
        Set colCpu =objswbemservices.execquery("select * from win32_processor")
        For Each item in colCpu
                cpuname =  (trim(item.name))
                WriteTable "中央处理器",cpuname
        Next
End Function 

Function MemoryWrite()
#函数，写入内存信息
mtotal        = 0
num         = 0
mill         = 0
	Set colMemory = objswbemservices.execquery("select * from win32_physicalmemory",,48)
	For Each objitem In colMemory
			mill = objitem.capacity/1048576
			WriteTable "单根内存容量",mill & "M"
			mtotal = mtotal+mill
			num = num + 1
	Next
	WriteTable "总计内存",num & "条" & "一共" & mtotal & "M"
End Function 

Function HarddiskWrite()
#函数，写入硬盘信息
	Set colDisk = objswbemservices.execquery("select * from win32_diskdrive", , 48)
	For Each objitem In colDisk
			diskname= objitem.caption
			disksize= fix(objitem.size/1073741824)
			WriteTable "硬盘",diskname & " 容量：" & disksize & "G"
	Next
End Function 



Function CdromWrite()
#函数，写入CDROM信息
	Set colCdrom = objswbemservices.execquery("select * from win32_cdromdrive where scsitargetid=0")
	For Each objitem In colCdrom
			cdname = objitem.name
			WriteTable "光驱",cdname
	Next
End Function

Function videoWrite()
#函数，写入显示卡信息
	Set colVideo = objswbemservices.execquery("select * from win32_videocontroller", , 48)
	For Each objitem in colVideo
			videoname = (trim(objitem.caption) & (objitem.videomodedescription)) 
			WriteTable "显示卡",videoname
	Next
End Function 


Function netcardWrite()
#函数，查询网卡信息
	Set colNetcards = objswbemservices.execquery("select * from win32_networkadapter")
	For Each objNetcard in colNetcards                        
	If Not IsNull(objNetcard.NetConnectionID) Then
			NetCardName         =  objNetcard.productname
				   WriteTable "网卡名称",NetCardName
	 
			If objNetcard.NetConnectionStatus = 2 Then                         
			NetCardMac         =  objNetcard.macaddress
			WriteTable "网卡Mac",NetCardMac

			strQueryIp ="select * from win32_networkadapterconfiguration" &_
							 " where IPEnabled = true" &_
							 " and macaddress = '" & objNetcard.macaddress & "'"
			Set colNetcardCfgs = objswbemservices.execquery(strQueryIp) 
			For Each objNetcardCfg in colNetcardCfgs                
					For Each CfgAdrress in objNetcardCfg.IPAddress
							IpAdrress = CfgAdrress
							WriteTable "IP地址",IpAdrress
					Next
			Next        

			Else

			NetCardMac = "网卡被禁用或未连接。"
			WriteTable "网卡Mac",NetCardMac
			IpAdrress = "网卡被禁用或未连接。"    
			WriteTable "IP地址",IpAdrress        
			
			End If
					
	End if    
	Next
End Function 

Function softlist()
#函数，写入软件信息
Set StdOut = WScript.StdOut 
Set oReg=GetObject("winmgmts:{impersonationLevel=impersonate}!\\" &_ 
strComputer & "\root\default:StdRegProv") 

strKeyPath = UNINSTALL_ROOT 

oReg.EnumKey HKEY_LOCAL_MACHINE, strKeyPath, arrSubKeys 

For Each strSubKey In arrSubKeys 
        If NotHotfix(strSubKey) Then                
                SoftNameAndVersion = getProgNameAndVersion(oReg,strKeyPath & "\" & strSubKey)
                If SoftNameAndVersion<>"0" Then 
                WriteTable "软件",SoftNameAndVersion                
                End If 
        End If
Next                 
End Function

Function NotHotfix(sSubKey)        
        If Left(sSubkey,2) = "KB" And len(sSubkey) = 8 Then
                NotHotfix = 0
        Else NotHotfix = 1
        End if
End Function

Function getProgNameAndVersion(oReg,sKeyRoot)
Dim sKeyValuesAry, iKeyTypesAry, nCnt, sValue, sDisplayName, sDisplayVersion
oReg.EnumValues HKEY_LOCAL_MACHINE, sKeyRoot, sKeyValuesAry, iKeyTypesAry
        If NOT IsArray(sKeyValuesAry) Then 
                getProgNameAndVersion = 0
                Exit Function  
        End If

        For nCnt = 0 To UBound(sKeyValuesAry)
                If InStr(1, sKeyValuesAry(nCnt), "DisplayName", vbTextCompare) Then
                        If iKeyTypesAry(nCnt) = REG_SZ Then
                                oReg.GetStringValue HKEY_LOCAL_MACHINE, sKeyRoot, sKeyValuesAry(nCnt), sValue
                                If sValue<>"" Then 
                                        sDisplayName = sValue                                
                                        sDisplayName = Replace(sDisplayName, "[", "(")
                                        sDisplayName = Replace(sDisplayName, "]", ")")
                                End If
                        End If
                ElseIf InStr(1, sKeyValuesAry(nCnt), "DisplayVersion", vbTextCompare) Then
                        If iKeyTypesAry(nCnt) = REG_SZ Then
                                oReg.GetStringValue HKEY_LOCAL_MACHINE, sKeyRoot, sKeyValuesAry(nCnt), sValue
                                If sValue<>"" Then sDisplayVersion = sValue
                        End If
                End If

                If (sDisplayName<>"") AND (sDisplayVersion<>"") Then 
                        getProgNameAndVersion = sDisplayName & " --版本号: " & sDisplayVersion
                        Exit Function
                Else         getProgNameAndVersion = 0                        
                End If
        Next

        If sDisplayName<>"" Then 
                getProgNameAndVersion = sDisplayName
                Exit Function                                        
        End If
End Function


Function WriteTable(caption,value)
#函数，将数据写入HTML单元格
resultFile.Writeline "<tr>"
resultFile.Writeline "<td align=""left"" width=""30%"" height=""25"" bgcolor=""#ffffff"" scope=""row"">  " & caption & "</td>"
resultFile.Writeline "<td bgcolor=""#ffffff"">  " & value & "</td>"
resultFile.Writeline "</tr>"
End Function 

Function HtmlWriteHead()
#函数，写入THML文件头
resultFile.Writeline "<html>" 
resultFile.Writeline "<head>" 
resultFile.Writeline "<title>软硬件配置清单</title>"
resultFile.Writeline "</head>" 
resultFile.Writeline "<body>" 
End Function 


Function HtmlWriteEnd()
#函数，写入Html文件尾
resultFile.Writeline "</body>" 
resultFile.Writeline "</html>" 
End Function 

Function TableHead(pcname,str)
#函数，写入Html表格结尾
resultFile.Writeline "<h3>" & pcname & str & " -- date:"&now()&" </h3>" & VbCrLf
resultFile.Writeline "<table width=""90%"" border=""0"" align=""center"" cellpadding=""0"" cellspacing=""1"" bgcolor=""#0000ff"">" 
resultFile.Writeline "<tr>" 
resultFile.Writeline "<th width=""30%"" height=""25"" bgcolor=""#ffffff"" scope=""col"">资产类型</th>"
resultFile.Writeline "<th bgcolor=""#ffffff"" scope=""col"">查询结果值</th>"
resultFile.Writeline "</tr>" 
strstyle = "<th width=""30%"" height=""25"" bgcolor=""#ffffff"" scope=""row"">"
End Function 

Function TableEnd()
#函数，Html表格结尾
resultFile.Writeline "</table>" 
End Function 
