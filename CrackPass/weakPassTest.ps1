$job=Start-Job -ScriptBlock{
	Sleep 5
	111111111
}

Function Execution-Script{
	$job=Start-Job -ScriptBlock{
		Sleep 5
		$path=$env:windir.subString(0,3)
		date>>"${path}+ttt.txt"
	}
	"{`"isSuccess`":`"true`",`"errorMsg`":`"测试成功`"}"
};
Execution-Script