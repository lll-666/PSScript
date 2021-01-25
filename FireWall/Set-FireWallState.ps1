Function Set-FireWallState{
	param(
		[ValidateSet('off','on')]
		[String]$state
	);
	Function IsSucc([Object[]] $str){
		$st=$str[-1].trim();
		$st=$st.subString(0,$st.Length-1).ToLower();
		Return ($st.EndsWith((UnicodeToChinese '\u786e\u5b9a')) -Or $st.EndsWith('ok'))
	}
	If((Get-Service mpssvc).Status -ne 'Running'){Set-Service mpssvc -StartupType Automatic;Start-Service mpssvc;}
	Foreach($profile In 'domainprofile','privateprofile','publicprofile'){
		$enable=Get-FireWallState $profile
		If((!$enable -And 'on' -eq $state) -Or ($enable -And 'off' -eq $state)){
			$tmp=(netsh advfirewall set $profile state $state)|select -First 3|WHere{![String]::isNullOrEmpty($_)}
			If(IsSucc $tmp){$res="Set $profile $state,%%SMP:executing-suffice;"+$res
			}Else{$res+="Set $profile $state,%%SMP:executing-fail;"}
		}Else{$res="Set $profile $state,%%SMP:detecting-suffice;"+$res}
	}
	Return $res.substring(0,$res.Length-1);
}