Function Parse-SecPol($CfgFile){
	$CfgFile.substring(0,$CfgFile.LastIndexOf('\'))
    secedit /export /cfg "$CfgFile" -raw| Out-null
    $obj = New-Object psobject
    $index = 0
    $contents = Get-Content $CfgFile 
    [regex]::Matches($contents,"(?<=\[)(.*)(?=\])") | %{
        $title = $_
        [regex]::Matches($contents,"(?<=\]).*?((?=\[)|(\Z))", [System.Text.RegularExpressions.RegexOptions]::Singleline)[$index] | %{
            $section = New-object psobject
            $_.value -split "\r\n" | ?{$_.length -gt 0} | %{
                $value = [regex]::Match($_,"(?<=\=).*").value
                $name = [regex]::Match($_,".*(?=\=)").value
                $section | Add-member -MemberType NoteProperty -Name $name.tostring().trim() -Value $value.tostring().trim() -ErrorAction SilentlyContinue | Out-null
            }
            $obj | Add-Member -MemberType NoteProperty -Name $title -Value $section
        }
        $index += 1
    }
    return $obj
}

Function Set-SecPol($SecPool, $CfgFile){
$SecPool
	$SecPool.psobject.Properties.GetEnumerator() | %{
        "[$($_.Name)]"
        $_.Value | %{
            $_.psobject.Properties.GetEnumerator() | %{
                "$($_.Name)=$($_.Value)"
            }
        }
    } | Out-file $CfgFile -ErrorAction Stop
    #secedit /configure /db c:\windows\security\local.sdb /cfg "$CfgFile" /areas SECURITYPOLICY
}
$CfgFile='C:\Test\Test.cgf'
$SecPool = Parse-SecPol -CfgFile $CfgFile
$SecPool.'System Access'.PasswordComplexity = 0#0-禁用,1-启用
$SecPool.'System Access'.MinimumPasswordLength = 6#密码长度
$SecPool.'System Access'.MaximumPasswordAge = 1#密码有效期
Set-SecPol -SecPool $SecPool -CfgFile $CfgFile