&"ls" == &'ls' == Invoke-Expression 'ls'  ==  Invoke-Expression "ls"
&后只能接命令，不能带参数和脚本，Invoke-Expression能接收任何脚本

&{}  &后接语句块，相当于匿名函数
& {param($people="everyone") write-host "Hello, $people " } "Mosser"


#脚本方式调用
param([int]$n=$(throw "请输入一个正整数"))
Function Factorial([int]$n){
    $total=1
    for($i=1;$i -le $n;$i++){$total*=$i}
    return $total
}
Factorial $n

#通过方法调用
Function Factorial{
    param([int]$n=$(throw "请输入一个正整数"))
	$total=1
    for($i=1;$i -le $n;$i++){$total*=$i}
    return $total
}
Factorial $n



get-process | & {
	begin {"开始准备环境"}
	process{$_.Name}
	end {"开始清理环境"}
}
get-process | %{$_.Name}