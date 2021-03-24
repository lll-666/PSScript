Function UnicodeToChinese([String]$sourceStr){
	[regex]::Replace($sourceStr,'\\u[0-9-a-f]{4}',{param($v);[char][int]($v.Value.replace('\u','0x'))})
}