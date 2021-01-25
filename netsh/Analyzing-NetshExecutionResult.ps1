Function Analyzing-NetshExecutionResult([ValidateSet('del','add')][String]$operate,[Object[]] $str){
	$str|Select -First 3|%{If(![String]::isNullOrEmpty($_)){$msg+=$_}}
	$Result=''|select isSuccess,msg;
	$Result.msg=$msg=$msg.Trim();
	$count=$str.Count;
	If('del' -eq $operate){
		If($count -eq 4 -Or $count -eq 3){$Result.isSuccess=$True}Else{$Result.isSuccess=$False}
	}ElseIf('add' -eq $operate){
		If($count -eq 2 -Or ($msg.EndsWith((UnicodeToChinese '\u786e\u5b9a')) -Or $msg.EndsWith('ok'))){$Result.isSuccess=$True}Else{$Result.isSuccess=$False}
		
	}
	Return $Result
}

show:
	$result.count>4		成功[xxxx有匹配规则输出]
	$result.count=3 	成功[没有与指定标准相匹配的规则。--No rules match the specified criteria.]

add:
	$result.count=2		成功[确定。--Ok.]
	$result.count=81	失败[A specified port value is not valid.--A specified protocol value is not valid.--A specified value is not valid.]
	$result.count=77	失败[指定的端口值无效。--指定的协议值无效。--指定的值无效。]
	$result.count=2		失败[请求的操作需要提升(作为管理员运行)。--The requested operation requires elevation (Run as administrator).]

delete:
	$result.count=4		成功[Deleted 1 rule(s).Ok.--已删除 1 规则。确定。]
	$result.count=3 	成功[没有与指定标准相匹配的规则。--No rules match the specified criteria.]
	$result.count=2		失败[请求的操作需要提升(作为管理员运行)。--The requested operation requires elevation (Run as administrator).]
	
	
$show=netsh advfirewall firewall show rule name=wwwww;$show.length;$show
$add=netsh advfirewall firewall add rule name=wwwww profile=any dir=in protocol=TCP localport=33322 action=block;$add.length;$add
$show=netsh advfirewall firewall show rule name=wwwww;$show.length;$show
$add=netsh advfirewall firewall add rule name=wwwww profile=any dir=in protocol=TCP localport=333221 action=block;$add.length;$add
$show=netsh advfirewall firewall show rule name=wwwww;$show.length;$show
$add=netsh advfirewall firewall add rule name=wwwww profile=any dir=in protocol=TCPs localport=33322 action=block;$add.length;$add
$show=netsh advfirewall firewall show rule name=wwwww;$show.length;$show
$add=netsh advfirewall firewall add rule name=wwwww profile=any dir=in protocol=TCP localport=33322 action=block1;$add.length;$add
$show=netsh advfirewall firewall show rule name=wwwww;$show.length;$show
$del=netsh advfirewall firewall delete rule name=wwwww;$del.length;$del
$show=netsh advfirewall firewall show rule name=wwwww;$show.length;$show	