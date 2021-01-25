Function Uninstall-SoftwareArr($hostUrl,$softwares){
	$suc=0;
	$res=1|Select isSuccess,msg,business;
	ConvertFrom-Csv $softwares|%{
		$ret=Black-Software $hostUrl (UnicodeToChinese $_.softwareName);$res.msg+="	$($_) :$ret";
		If(Is-Success $ret){$suc+=1}
	}
	$res.isSuccess=$suc -eq ($softwares.length-1);
	$res.business='Uninstall-SoftwareArr';
	Return ConvertToJson $res
}

<#
!!以上代码均为固定模式,非专业人士不要修改!!
!!以下代码为调度部分;调度部分用法如下
不可修改部分:
	"Uninstall-SoftwareArr"	=>调度方法
	"softwareName" 		=>软件名导航字段
可修改部分: 
	软件名,用户可根据实际业务需要进行新增或删除,若软件名为空中文,请先将其换成Unicode编码,以规避不同系统环境乱码并导致无法正常执行
	$hostUrl 应修改为软件安装包的下载地址
功能:
	卸载wifi代理工具
格式: Uninstall-SoftwareArr $hostUrl @( "softwareName" ,"软件名1",...,"软件名n" )
#>
#Uninstall-SoftwareArr "http://172.17.8.56:9888//nodeManager/file/download/" @("softwareName","360免费WiFi","猎豹免费WIFI","WiFi共享大师")
Uninstall-SoftwareArr "http://172.17.8.56:9888//nodeManager/file/download/" @("softwareName","360\u514d\u8d39WiFi","\u730e\u8c79\u514d\u8d39WIFI","WiFi\u5171\u4eab\u5927\u5e08")