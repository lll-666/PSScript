<#
Add-Type -ReferencedAssemblies System.Core @'
	using System.Collections.Generic;
	public class HSet{
		public HashSet<string> set = new HashSet<string>();
	}
'@

cd C:\Users\Administrator\Desktop\天马账户属性
$base = Import-Csv .\天马账户属性修复结果-成功.csv -Encoding utf8
$hset = New-Object HSet;
$base|%{$hset.set.Add($_.BIOSID)}
#>

<#
$array = @('One', 'Two', 'Three')
$parameters = @{
    TypeName = 'System.Collections.Generic.HashSet[string]'
    ArgumentList = ([string[]]$array, [System.StringComparer]::OrdinalIgnoreCase)
}
$set = New-Object @parameters
#>


$baseDir='C:\Users\Administrator\Desktop\天马账户属性';cd $baseDir
$basePath=Join-Path $baseDir 天马账户属性修复结果-成功.csv

$base = Import-Csv $basePath -Encoding utf8
$HashTable=@{}
$base|%{$HashTable.$($_.BIOSID)=$_}
$keys=$HashTable.keys
<#
$parameters = @{
    TypeName = 'System.Collections.Generic.HashSet[string]'
    ArgumentList = ([string[]]$keys, [System.StringComparer]::OrdinalIgnoreCase)
}
$set = New-Object @parameters
#>
#同上
$set = New-Object -TypeName System.Collections.Generic.HashSet[string] -ArgumentList @([string[]]$keys,[System.StringComparer]::OrdinalIgnoreCase)
$desDir='C:\Users\Administrator\Desktop\天马账户属性\3-09-res2\logDir\'
$files = ls $desDir
foreach($file in $files){
	$newData = Import-Csv $file.FullName -Encoding utf8
	foreach($data in $newData){
		If(!$data.BIOSID){Continue}
		If(!$set.Contains($data.BIOSID)){
			write-host $data
			$data|select date,ip,pass,OSID,BIOSID,CPUID,ProductId,ipsStr,mac,enabledMacs,enabledNoVMMacs|
				ConvertTo-Csv|
					select -Skip 2|
						Out-File $basePath -Encoding UTF8 -Append
			
		}
	}
}
