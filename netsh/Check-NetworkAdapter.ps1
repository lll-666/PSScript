Function Execution-Script{
	param(
		[String] $param1,
		[Bool] $param2
	)
	
	<#该脚本仅为示例,中间业务部分省去#>
	
	$Result=''|select isSuccess,errorMsg,retObj;
	$Result.isSuccess=$False;
	$Result.errorMsg='获取xxx信息失败';
	$Result.retObj=$Null;
	Return $Result;
};Function ConvertToJson{
	param($InputObject);
	if($InputObject -is [string]){
		if(![String]::isNullOrEmpty($InputObject)){$InputObject=$InputObject.replace('\','/').trim()}
		"`"{0}`"" -f $InputObject
	}elseif($InputObject -is [bool]){
		$InputObject.ToString().ToLower();
	}elseif($InputObject -eq $null){
		"null"
	}elseif($InputObject -is [pscustomobject]){
		$result="{";
		$properties=$InputObject|Get-Member -MemberType NoteProperty|ForEach-Object{
			if(![String]::isNullOrEmpty($_.Name)){"`"{0}`":{1}" -f  $_.Name,(ConvertToJson $InputObject.($_.Name))}
		};
		$result+=$properties -join ",";
		$result+="}";
		$result
	}elseif($InputObject -is [hashtable]){
		$result="{";
		$properties=$InputObject.Keys|ForEach-Object{
			if(![String]::isNullOrEmpty($_)){"`"{0}`":{1}" -f  $_,(ConvertToJson $InputObject[$_])}
		};
		$result+=$properties -join ",";
		$result+="}";
		$result
	}elseif($InputObject -is [array]){
		$result="[";
		$items=@();
		for($i=0;$i -lt $InputObject.length;$i++){
			if(![String]::isNullOrEmpty($InputObject[$i])){$items+=ConvertToJson $InputObject[$i]}
			
		}
		$result+=$items -join ",";
		$result+="]";
		$result
	}else{
		"`"{0}`"" -f $InputObject.ToString().trim()
	}
}
Execution-Script -param1 $null -param2 $True|%{ConvertToJson $_}