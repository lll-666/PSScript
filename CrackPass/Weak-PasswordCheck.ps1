Function Weak-PasswordCheck{
	param(
		[String] $passAddr='http://172.17.8.218:9888',
		[bool] $isReCheck=$False,
		[int] $expires=180
	)
	$passAddr+="/nodeManager/file/download/pwdDb.csv"
	$dbPath=$env:SystemDrive+"\Program Files\Ruijie Networks\passdb"
	If(!(Test-Path $dbPath)){mkdir $dbPath|Out-Null}
	$accs=@();
	Get-WmiObject Win32_userACcount|Where{$_.__SERVER -eq $_.domain -And $_.name -ne $env:username -And $_.status -eq 'ok'}|%{$accs+=$_.name}
	If($accs.count -eq 0){Return (New-Object PSObject -Property @{userName='';status='complete_noDetect';pass='';})}
	$res=@()
	$outPath="${dbPath}\res.csv"
	If(!(Test-Path $outPath) -Or $isReCheck){
		"userName,pass,status">$outPath
	}Else{
		$tmps=Import-Csv $outPath
		[System.Collections.ArrayList]$accs=$accs
		Foreach($tmp in $tmps){
			If($accs -contains $tmp.userName){
				$accs.remove($tmp.userName);
				$res+=$tmp
			}
		}
	}
	$pwdPath="${dbPath}/pwdDb.csv"
	If($accs.length -ge 0){
		If(!(Test-Path $pwdPath)){
			Download-File $passAddr $pwdPath|Out-Null
		}
		Foreach($acc in $accs){
			$res+=New-Object PSObject -Property @{userName=$acc;status='detecting';pass='';}
			$accFlag="${dbPath}/$acc"
			If(Test-Path $accFlag){
				If((([datetime](ls $accFlag).LastWriteTime).compareTo((Get-Date).AddMinutes(-($expires)))) -eq -1){
					rm $accFlag -Force
				}Else{continue}
			}
			$mutex=$false;
			$obj = New-Object System.Threading.Mutex ($true,$acc,[ref]$mutex)
			If($mutex){
				New-Item  $accFlag -ItemType "file"|Out-Null
				$obj.ReleaseMutex() | Out-Null
				$obj.Dispose() | Out-Null
			}Else{continue}
			If($passes -eq $null){$passes=Import-Csv $pwdPath}
			$job=Start-Job -ScriptBlock{
				Function Out-Res([String] $msg){
					$res=Import-Csv $outPath;
					Foreach($re in $res){
						If($acc -eq $res.userName){Return}
					}
					$msg>>$outPath
				}
				Try{				
					[System.Reflection.Assembly]::LoadWithPartialName('System.DirectoryServices.AccountManagement')|Out-Null
					$pc=New-Object -TypeName System.DirectoryServices.AccountManagement.PrincipalContext 'Machine',$env:COMPUTERNAME
					$acc=$args[0];
					$passes=$args[1];
					$outPath=$args[2];
					If($pc.ValidateCredentials($acc,'')){Out-Res "$acc,,complete_noPassowrd"}
					Foreach($pass in $passes){
						If($pc.ValidateCredentials($acc,$pass.pwd)){Out-Res ("$acc,"+$pass.pwd+",complete_matched")}
					}
					Out-Res "$acc,,complete_noMatch"
				}Catch{
					$dir=(ls $outPath).DirectoryName;
					rm $($dir+'\'+$acc) -Force
					"$((Get-Date).tostring());check [$acc] Exception,The Exception is $($error[0])">>$($dir+'\exception')
				}
			} -ArgumentList $acc,$passes,$outPath;
		}
	}
	Return $res;
}
$rr=RunJobSync 'http://172.17.8.218:9888'
$isSuccess='true'
Foreach($r in $rr){
	If(!$r.status.startsWith('complete')){
		$isSuccess='false';break
	}
}
$json=ConvertToJson $rr
If(!$json.startsWith('[')){$json='['+$json+']'}
"{`"isSuccess`":`"$isSuccess`",`"retObj`":$json}"