#输出3个异常;默认:未捕获异常了,输出异常,并继续执行后续任务
Function Test-Func{
Trap{"Trap 到异常了."}
1/$null
Get-Process "NoSuchProcess"
Dir MossFly:
}
Test-Func

#输出1个异常;未捕获异常了,输出异常,并终止执行后续任务
Function Test-Func{
Trap{ 
"Trap 到异常了.";
break
}
1/$null
Get-Process "NoSuchProcess"
Dir MossFly:
}
Test-Func

#输出2个异常;捕获了异常(可选择输出当前异常),并继续执行后续任务
Function Test-Func{
Trap{"Trap 到异常了.";continue}
1/$null
Get-Process "NoSuchProcess"
Dir MossFly:
}
Test-Func

#输出0个异常;捕获了异常(可选择输出当前异常),并终止执行后续任务
Function Test-Func{
Trap{"Trap 到异常了.";return}
1/$null
Get-Process "NoSuchProcess"
Dir MossFly:
}
Test-Func

Function Test-Func{
Trap {
"Trap到了异常: $($_.Exception.Message)";
Continue
}
1/$null
Get-Process "NoSuchProcess" -ErrorAction  SilentlyContinue
Dir MossFly
}
Test-Func


Function Test-Func{
Trap {Continue}
1/$null
Get-Process "NoSuchProcess" -ErrorAction Stop
Dir MossFly: -ErrorAction Stop
}
Test-Func