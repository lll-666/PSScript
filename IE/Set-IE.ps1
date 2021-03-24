IE设置的注册表相关信息以及修改方法：

IE 的安全属性设置是放置在注册表的以下位置的：
HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones
其中 UserName 是指当前进入系统的用户所使用的用户名
在 Zones 主键下又有 0、1、2、3、4 五个主键，分别的含义是： 
0：您的计算机本地的设置
1：本地 Intranet
2：可信站点
3：Internet
4：受限站点


let shell = new ActiveXObject("WScript.Shell");
shell.RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3\1405","0","REG_DWORD");

参考链接：http://www.360doc.com/content/14/0626/16/17267365_390020488.shtml


允许本地文件ActiveX正常运行
IE高级选项：允许活动内容在我的计算机上的文件中运行 选中 对应的注册表选项
[HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_LOCALMACHINE_LOCKDOWN]
"iexplore.exe"=dword:00000000//禁用设为1
[HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_LOCALMACHINE_LOCKDOWN\Settings]
"LOCALMACHINE_CD_UNLOCK"=dword:00000000

注册表路径：
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones
1.Zones 项包含表示为计算机定义的每个安全区域的项。默认情况下，定义以下 5个区域（编号从 0  到  4）：
  值                   设置 
------------------------------ 
  0                 我的电脑 
  1                 本地   Intranet   区域 
  2                 受信任的站点区域 
  3                 Internet   区域 
  4                 受限制的站点区域 

  注意：默认情况下，“我的电脑”不会出现在“安全”选项卡的“区域”框中。 
  其中的每项都包含以下DWORD值，用于表示自定义“安全”选项卡上的相应设置。 
  
  
  注意：除非另外声明，否则每个DWORD值等于0、1或3。通常，设置为0则将具体操作设置为允许；设置为 1则导致出现提示；设置为 3则禁止执行具体操作。
2.         值设置说明：
  值               设置 
-----------------------------------------------------------------------
  1001           下载已签名的ActiveX控件
  1004           下载未签名的 ActiveX控件
  1200           运行ActiveX控件和插件
  1201           对没有标记为安全的ActiveX控件进行初始化和脚本运行
  1206           允许Internet Explorer Webbrowser控件的脚本
  1400           活动脚本
  1402           Java小程序脚本
  1405           对标记为可安全执行脚本的ActiveX控件执行脚本
  1406           通过域访问数据资源
  1407           允许通过脚本进行粘贴操作
  1601           提交非加密表单数据
  1604           字体下载
  1605           运行Java
  1606           持续使用用户数据
  1607           跨域浏览子框架
  1608           允许META  REFRESH   *
  1609           显示混合内容   *
  1800           桌面项目的安装
  1802           拖放或复制和粘贴文件
  1803           文件下载
  1804           在 IFRAME中加载程序和文件
  1805           在 Web视图中加载程序和文件 
  1806           加载应用程序和不安全文件
  1807           保留   **
  1808           保留   **
  1809           使用弹出窗口阻止程序   **
  1A00           登录 
  1A02           允许持续使用存储在计算机上的   Cookie 
  1A03           允许使用每个会话的   Cookie（未存储） 
  1A04           没有证书或只有一个证书时不提示选择客户证书   * 
  1A05           允许持续使用第三方   Cookie   * 
  1A06           允许使用第三方会话   Cookie   * 
  1A10           隐私设置   * 
  1C00           Java权限 
  1E05           软件频道权限 
  1F00           保留   ** 
  2000           二进制和脚本行为 
  2001           运行已用   Authenticode   签名的   .NET   组件 
  2004           运行未用   Authenticode   签名的   .NET   组件 
  2100           基于内容打开文件，而不是基于文件扩展名   ** 
  2101           在低特权   Web   内容区域中的网站可以导航到此区域   ** 
  2102           允许由脚本初始化的窗口，没有大小和位置限制   ** 
  2200           文件下载自动提示   ** 
  2201           ActiveX   控件自动提示   ** 
  2300           允许网页为活动内容使用受限制的协议   ** 

 {AEBA21FA-782A-4A90-978D-B72164C80120}       第一方   Cookie   * 
 {A8A88C49-5EB2-4990-A1A2-0876022C854F}       第三方   Cookie   * 

  *   表示   Internet   Explorer   6   或更高版本设置 
  **  表示   Windows   XP   Service   Pack   2   或更高版本设置  

3.IE浏览器->属性->高级里的"禁止脚本调试(其他)"的设置在注册表里的位置 ：
HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main\Disable Script Debugger (0为启用，1为禁止)

4.IE浏览器->属性->高级里的"禁止脚本调试(IE)"的设置在注册表里的位置：
HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main\  DisableScriptDebuggerIE (0为启用，1为禁止)

5.修改IE默认安全的级别：
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3
将“MinLevel”修改为“10000”(十六进制)，这样就可以设置为更低的安全级别了 

6. 附javaScript修改注册表例子：
<SCRIPT language=javascript>
<!-- 
var WshNetwork = new ActiveXObject("WScript.Network");
ComputerName=WshNetwork.ComputerName+"/"+WshNetwork.UserName;
//读注册表中的计算机名
var obj = new ActiveXObject("WScript.Shell");
var path="HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings\\Zones";//注册表关于安全设置路径
var advance="HKEY_CURRENT_USER\\Software\\Microsoft\\Internet Explorer\\Main";//注册表关于高级设置路径
var forward="http://10.149.4.14:9080/sundun_nn/login.jsp";//修改成功后跳转到的页面
var levelPath="HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings\\Zones";
//把网站添加到受信任站点
var savePath="HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings\\ZoneMap\\Domains";//添加到受信任站点的注册表路径
var domain="sundun.cn";//域名
var protocol="http";//协议
var qianz="www";//前缀
obj.RegWrite(savePath+"\\"+domain,"");
obj.RegWrite(savePath+"\\" + domain + "\\"+qianz,"");
obj.RegWrite(savePath+"\\" + domain + "\\"+qianz+"\\"+protocol,"2","REG_DWORD");

//IE浏览器——>工具——>Internet选项——>安全——>本地Intranet——>显示混合内容
var str0=path+"\\1\\1609";
//alert(obj.RegRead(str0));
if(obj.RegRead(str0)!='0'){//如果已经修改则跳过
       obj.RegWrite(str0,0x00000000,"REG_DWORD");
}

 

//修改IE默认的安全级别

var levelStr=levelPath+"\\2\\MinLevel";

if(obj.RegRead(levelStr)!='10000'){
       obj.RegWrite(levelStr,"10000");
}

//IE浏览器——>工具——>Internet选项——>安全——>受信任的站点——>显示混合内容a
var str11=path+"\\2\\1609";
if(obj.RegRead(str11)!='0'){
       obj.RegWrite(str11,0x00000000,"REG_DWORD");
}
var str12=path+"\\2\\1001";//下载已签名的 ActiveX 控件

if(obj.RegRead(str12)!='0'){
       obj.RegWrite(str12,0x00000000,"REG_DWORD");
}

var str13=path+"\\2\\1004";//下载未签名的 ActiveX  控件
if(obj.RegRead(str13)!='0'){
       obj.RegWrite(str13,0x00000000,"REG_DWORD");
}

var str14=path+"\\2\\1200";//运行 ActiveX 控件和插件

if(obj.RegRead(str14)!='0'){
       obj.RegWrite(str14,0x00000000,"REG_DWORD");
}

var str15=path+"\\2\\1201";//对没有标记为安全的 ActiveX 控件进行初始化和脚本运行
if(obj.RegRead(str15)!='0'){
       obj.RegWrite(str15,0x00000000,"REG_DWORD");
}

var str16=path+"\\2\\1405";//对标记为可安全执行脚本的 ActiveX 控件执行脚本
if(obj.RegRead(str16)!='0'){
       obj.RegWrite(str16,0x00000000,"REG_DWORD");
}

 

//IE浏览器——>工具——>Internet选项——>安全——>Internet——>ActiveX 控件自动提示

var str2=path+"\\3\\2201";

if(obj.RegRead(str2)!='0'){
       obj.RegWrite(str2,0x00000000,"REG_DWORD");
}
//IE浏览器——>工具——>Internet选项——>安全——>Internet——>对标记为可安全执行脚本的 ActiveX 控件执行脚本
var str3=path+"\\3\\1405";
if(obj.RegRead(str3)!='0'){
       obj.RegWrite(str3,0x00000000,"REG_DWORD");
}

//IE浏览器——>工具——>Internet选项——>安全——>Internet——>显示混合内容
var str4=path+"\\3\\1609";
if(obj.RegRead(str4)!='0'){
       obj.RegWrite(str4,0x00000000,"REG_DWORD");
}
//IE浏览器——>工具——>Internet选项——>高级里的"禁止脚本调试(其他)"
var str5=advance+"\\Disable Script Debugger";
if(obj.RegRead(str5)!='0'){
       obj.RegWrite(str5,"yes");
}
//IE浏览器——>工具——>Internet选项——>高级里的"禁止脚本调试(IE)"
var str6=advance+"\\DisableScriptDebuggerIE";
if(obj.RegRead(str6)!='0'){
       obj.RegWrite(str6,"yes");

}

//IE浏览器——>工具——>Internet选项——>高级里的"允许活动内容在我的计算机上的文件运行"
var str7=advance+"\\FeatureControl\\FEATURE_LOCALMACHINE_LOCKDOWN\\iexplore.exe";
if(obj.RegRead(str7)!='0'){
       obj.RegWrite(str7,0x00000000,"REG_DWORD");

}
</SCRIPT>

实例:
try{ 
var obj = new ActiveXObject("WScript.Shell");
var path="HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings";//注册表关于安全设置路径
var advance="HKEY_CURRENT_USER\\Software\\Microsoft\\Internet Explorer\\Main";//注册表关于高级设置路径
var levelPath="HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings\\Zones";
var zspath="HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\WinTrust\\Trust Providers\\Software Publishing";
//下载已签名的 ActiveX 控件
var str1=path+"http://www.cnblogs.com/fujinliang/admin/file://zones31001/";
if(obj.RegRead(str1)!='0'){
 obj.RegWrite(str1,0x00000000,"REG_DWORD");
 alert("下载已签名的 ActiveX 控件");
}

//IE浏览器——>工具——>Internet选项——>安全——>Internet——>ActiveX 控件自动提示
var str2=path+"http://www.cnblogs.com/fujinliang/admin/file://zones32201/";
if(obj.RegRead(str2)!='0'){
 obj.RegWrite(str2,0x00000000,"REG_DWORD");
 alert("ActiveX 控件自动提示");
}

//IE浏览器——>工具——>Internet选项——>安全——>Internet——>对标记为可安全执行脚本的 ActiveX 控件执行脚本
var str3=path+"http://www.cnblogs.com/fujinliang/admin/file://zones31405/";
if(obj.RegRead(str3)!='0'){
 obj.RegWrite(str3,0x00000000,"REG_DWORD");
 alert("对标记为可安全执行脚本的 ActiveX 控件执行脚本");
}
//IE浏览器——>工具——>Internet选项——>安全——>Internet——>显示混合内容
var str4=path+"http://www.cnblogs.com/fujinliang/admin/file://zones31609/";
if(obj.RegRead(str4)!='0'){
 obj.RegWrite(str4,0x00000000,"REG_DWORD");
 alert("显示混合内容");
}
//IE浏览器——>工具——>Internet选项——>安全——>Internet——>没有证书或只有一个证书时不提示选择客户证书
var str5=path+"http://www.cnblogs.com/fujinliang/admin/file://zones31a04/";
if(obj.RegRead(str5)!='0'){
 obj.RegWrite(str5,0x00000000,"REG_DWORD");
 alert("没有证书或只有一个证书时不提示选择客户证书");
}
//IE浏览器——>工具——>Internet选项——>安全——>Internet——>提交非加密表单数据
var str6=path+"http://www.cnblogs.com/fujinliang/admin/file://zones31601/";
if(obj.RegRead(str6)!='0'){
 obj.RegWrite(str6,0x00000000,"REG_DWORD");
 alert("提交非加密表单数据");
}
}catch(e){
 alert("请将您浏览器Internet选项中的“对没有标记为安全的ActiveX控件进行初始化和脚本运行”设置为“启用”！\n\n然后刷新本页登陆！"); 
}




Internet Explorer->Internet选项->隐私->
	站点
		要允许或阻止的网站地址->
	清除站点
		
	弹出窗口阻止程序
		启用弹出窗口阻止程序->设置->阻止级别
		
	InPrivate
	
注册表
regedit
HKEY_LOCAL_MACHINE\Software\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_WEBOC_POPUPMANAGEMENT
Iexplore.exe
	0或1
	
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones
HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones
	对于每个区域下的 1809，
	数据值 3 表示禁用弹出窗口阻止程序
	数据值 0 表示启用弹出窗口阻止程序
	
	
gpedit.msc	
	用户配置->管理模板->Windows 组件->Internet Explorer->
	
	用户配置->管理模板->Windows 组件->Internet Explorer->Internet 控制面板->安全页
	
	regsvr32 actxprxy.dll
	
https://zhidao.baidu.com/question/165897025.html