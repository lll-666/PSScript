Function ConvertToJson{
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