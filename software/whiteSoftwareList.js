db.psScriptTemplate.remove({name:"White-Software"});
db.psScriptTemplate.save({
  "_id" : ObjectId("5e6f385fa0ff38f9cc08b6b2"),
  "name" : "White-Software",
  "desc" : "软件白名单脚本模板",
  "params" : [{
      "name" : "~hostUrl~",
      "defaultValue" : "$null",
      "type" : "String"
    }, {
      "name" : "~softwareName~",
      "defaultValue" : "$null",
      "type" : "String"
    }, {
      "name" : "~softwareVersion64~",
      "defaultValue" : "$null",
      "type" : "String"
    }, {
      "name" : "~fileName64~",
      "defaultValue" : "$null",
      "type" : "String"
    }, {
      "name" : "~softwareVersion32~",
      "defaultValue" : "$null",
      "type" : "String"
    }, {
      "name" : "~fileName32~",
      "defaultValue" : "$null",
      "type" : "String"
    }],
  "analyzingContent" : "package com.ruijie.authentication.session.program.domain.program;\r\ndialect  \"java\"\r\nimport com.ruijie.authentication.session.program.domain.program.PsScriptTemplateAnalyzingProcedureFact\r\nimport com.ruijie.authentication.authnode.domain.node.compliance.ComplianceDetectingResultState\r\nrule \"classify\"\r\nwhen\r\n    fact:PsScriptTemplateAnalyzingProcedureFact()\r\nthen\r\n    if(!fact.getScriptResponse().getResponse().endsWith(\"%%SMP:success\")){\r\n        fact.setResultState(ComplianceDetectingResultState.COMPLIANCE_FAIL);\r\n        fact.setResponse(fact.getScriptResponse().getResponse());\r\n    }\r\nend",
  "content" : "Function White-Software{\r\n\tparam([String] $hostUrl,\r\n\t\t[String] $softwareName,\r\n\t\t[String] $softwareVersion64,\r\n\t\t[String] $fileName64,\r\n\t\t[String] $softwareVersion32,\r\n\t\t[String] $fileName32,\r\n\t\t[bool] $silent=$false\r\n\t);\r\n\tIf([String]::isNullOrEmpty($softwareName)){Return \"BusinessException:softwareName can not empty\"}\r\n\tIf([String]::isNullOrEmpty($hostUrl)){Return \"BusinessException:hostUrl can not empty\"}\r\n\tIf([String]::isNullOrEmpty($fileName64) -and [String]::isNullOrEmpty($fileName32)){Return \"BusinessException:install package can not empty\"}\r\n\t\r\n\tIf($softwareName -like '*guard*'){\r\n\t\t$Res = Set-Processd -processName WINRDLV3 -isRun $true -startFile \"$($env:SystemDrive)\\WINDOWS\\system32\\winrdlv3.exe\";$Res;\r\n\t\tIf(Is-Success $Res){Return}\r\n\t}\r\n\t\r\n\t$downloadPath = Join-Path $env:SystemDrive '/Program Files/Ruijie Networks/softwarePackage/';\r\n\tIf(!(Test-Path $downloadPath)){mkdir $downloadPath -Force|Out-Null}\r\n\tIf([IntPtr]::Size -eq 4){\r\n\t\tIf([String]::isNullOrEmpty($fileName32)){Return Ret-Success \"no installation package32 available, default and pass\"}\r\n\t\t$softwareVersion=$softwareVersion32;\r\n\t\t$bit='bit32';\r\n\t\t$fileName=$fileName32\r\n\t}Else{\r\n\t\tIf([String]::isNullOrEmpty($fileName64)){Return Ret-Success \"no installation package64 available, default and pass\"}\r\n\t\t$softwareVersion=$softwareVersion64;\r\n\t\t$bit='bit64';\r\n\t\t$fileName=$fileName64;\r\n\t}\r\n\r\n\tIf((Get-SoftwareInfoByNameVersion $softwareName $softwareVersion) -ne $null){Return Ret-Success \"${softwareName} has been installed\"}\r\n\t$softwarePath = Join-Path $downloadPath $fileName;\r\n\tIf(!(Test-Path \"$softwarePath\") -or (cat \"$softwarePath\" -TotalCount 1) -eq $null){\r\n\t\t$tmp=Handle-SpecialCharactersOfHTTP \"?fileName=$fileName&dir=win/$bit\";\r\n\t\t$remoteSoftwarePath=$hostUrl+'/temp'+$tmp;\r\n\t\t$Res=Download-File \"$remoteSoftwarePath\" \"$softwarePath\";\"$Res\";\r\n\t\tIf(!(Is-Success $Res)){Return}\r\n\t}\r\n\t\r\n\t$file=ls $softwarePath;\r\n\tIf($null -ne (ps|?{$_.name -eq $file.baseName -And ($_.path -eq $null -Or $_.path -eq $softwarePath)})){Return \"$($file.name) is Installing\"}\r\n\t\r\n\tIf('.msi' -eq $file.Extension){\r\n\t\tIf($silent){\r\n\t\t\t$null=iex \"& cmd /c `'msiexec.exe /i `\"$softwarePath`\"`' /norestart /qn ADVANCED_OPTIONS=1 CHANNEL=100\"  -ErrorAction SilentlyContinue\r\n\t\t}Else{\r\n\t\t\t$null=iex \"& cmd /c `'msiexec.exe /i `\"$softwarePath`\"`' ADVANCED_OPTIONS=1 CHANNEL=100\"  -ErrorAction SilentlyContinue\r\n\t\t}\r\n\t\tIf(!$?){Return Print-Exception \"Msiexec /i `\"$softwarePath`\" /norestart /qn\"}\r\n\t}else{\r\n\t\t$Res=OperatorSoftwareBySWI $hostUrl $softwarePath $silent;\"$Res\";\r\n\t\tIf(!(Is-Success $Res)){Return}\r\n\t}\r\n\tIf((Get-SoftwareInfoByNameVersion $softwareName $softwareVersion) -eq $null){Return \"BusinessException:Installation of the software has not been successful\"}\r\n\tReturn Ret-Success \r\n}",
  "callContent" : "White-Software ~hostUrl~ ~softwareName~ ~softwareVersion64~ ~fileName64~ ~softwareVersion32~ ~fileName32~",
  "subNames" : ["Ret-Success", "Is-Success", "Print-Exception", "Download-File", "Get-SoftwareInfoByNameVersion", "OperatorSoftwareBySWI", "Handle-SpecialCharactersOfHTTP", "Set-Processd"],
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})

db.psScriptTemplate.remove({name:"OperatorSoftwareBySWI"});
db.psScriptTemplate.save({
  "_id" : ObjectId("5e6f385fa0ff38f9cc08b6b8"),
  "name" : "OperatorSoftwareBySWI",
  "desc" : "通过SWI安装或卸载软件",
  "content" : "Function OperatorSoftwareBySWI([String]$hostUrl,[String]$softwarePath,$isSilent=$True){\r\n\t$business=\"[OperatorSoftwareBySWI:$softwarePath]=>>\"\r\n\tIf([String]::IsNullOrEmpty(\"$softwarePath\")){\r\n\t\tReturn \"uninstall script not exist\"\r\n\t}\r\n\tIf(!$softwarePath.EndsWith(\".exe\") -And !$softwarePath.EndsWith(\".exe`\"\")){\r\n\t\tReturn \"uninstall script format error[$softwarePath]\"\r\n\t}\r\n\tIf($softwarePath.StartsWith('\"')){\r\n\t\t$softwarePath=$softwarePath.substring(1,$softwarePath.LastIndexOf('\"'))\r\n\t}\r\n\t$SWIDir=Join-Path $env:SystemRoot 'System32';\r\n\tIf(!(Test-Path $SWIDir)){\r\n\t\tmkdir $SWIDir -Force|Out-Null;\r\n\t\tIf(!$?){Return Print-Exception \"${business}mkdir $SWIDir -Force|Out-Null\"}\r\n\t}\r\n\t\r\n\tIf([IntPtr]::Size -eq 8){$SWIFileName='SWIService64.exe'}Else{$SWIFileName='SWIService.exe';}\r\n\t$SWIPath=Join-Path $SWIDir $SWIFileName;\r\n\t$SWIServiceName='SWIserv';\r\n\tIf (!(Test-Path \"$SWIPath\")){\r\n\t\tIf([String]::IsNullOrEmpty(\"$hostUrl\")){Return \"When downloading the installation package, the host address cannot be empty\"}\r\n\t\t$remoteexePath=\"$hostUrl/$SWIFileName\";\r\n\t\t$Res=Download-File \"$remoteexePath\" \"$SWIPath\";\"$business$Res\";\r\n\t\tIf(!(Is-Success $Res)){Return}\r\n\t}\r\n\t\r\n\tRestart-Service $SWIServiceName -ErrorAction SilentlyContinue;\r\n\tIf(!$?){\r\n\t\tTry{\r\n\t\t\tIf((gsv -Name $SWIServiceName -ErrorAction SilentlyContinue) -ne $null){sc.exe delete $SWIServiceName}\r\n\t\t\tcd $SWIDir;\r\n\t\t\tiex \".\\$SWIFileName  -install -ErrorAction Stop\"\r\n\t\t}Catch{\r\n\t\t\tReturn Print-Exception \"${business}Restart-Service -Name $SWIServiceName\"\r\n\t\t}\r\n\t}\r\n\t\r\n\tspsv -Name $SWIServiceName -ErrorAction SilentlyContinue;\r\n\tIf(!$?){Return Print-Exception \"${business}spsv -Name $SWIServiceName\"}\r\n\t\r\n\tTry{\r\n\t\tIf(!$isSilent){$p=''}Else{$p='/s'}\r\n\t\t(gsv -Name $SWIServiceName).Start(\"{`\"exe`\":`\"$softwarePath`\",`\"arg`\":`\"$p`\"}\")\r\n\t}Catch{\r\n\t\tReturn Print-Exception \"${business}(gsv -Name $SWIServiceName).Start(\"+'\"{`\"exe`\":'+\"$softwarePath\"+',`\"arg`\":`\"/s`\"}\")'\r\n\t}\r\n\tReturn Ret-Success $business\r\n}",
  "callContent" : "OperatorSoftwareBySWI $hostUrl $softwarePath $isSilent",
  "subNames" : ["Ret-Success", "Is-Success", "Print-Exception", "Download-File"],
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})

db.psScriptTemplate.remove({name:"Handle-SpecialCharactersOfHTTP"});
db.psScriptTemplate.save({
  "_id" : ObjectId("5e7322bd91135576c89082bc"),
  "name" : "Handle-SpecialCharactersOfHTTP",
  "desc" : "处理Http请求值中包含的特殊符",
  "params" : [{
      "name" : "~Characters~",
      "defaultValue" : "$null",
      "type" : "String"
    }],
  "content" : "Function Handle-SpecialCharactersOfHTTP([String] $Characters){\r\n\tIf([String]::IsNullOrEmpty($Characters)){\r\n\t\tReturn $Null;\r\n\t}\r\n\t#[空格:%20 \":%22 #:%23 %:%25 &用%26 +:%2B ,:%2C /:%2F ::%3A ;:%3B <:%3C =:%3D >:%3E ?:%3F @:%40 \\:%5C |:%7C]\r\n\tReturn $Characters.replace(' ','%20').replace('+','%2B').replace('/','%2F').replace('(','%28').replace(')','%29')\r\n}",
  "callContent" : "Handle-SpecialCharactersOfHTTP ~Characters~",
  "subNames" : [],
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})

db.psScriptTemplate.remove({name:"Download-File"});
db.psScriptTemplate.save({
  "_id" : ObjectId("5e6f385fa0ff38f9cc08b6b6"),
  "name" : "Download-File",
  "desc" : "文件下载(软件安装包,工具文件等)",
  "content" : "Function Download-File([String]$src,[String]$des,[bool]$isReplace=$false){\r\n\tIf([String]::IsNullOrEmpty($src)){Return \"BusinessException:Source file does not exist\"}\r\n\tIf([String]::IsNullOrEmpty($des)){Return \"BusinessException:Destination address cannot be empty\"}\r\n\tIf(Test-Path $des){\r\n\t\twhile (Test-FileLocked $des){\r\n\t\t\tsleep 1;\r\n\t\t\tIf($i++ -gt 1){Return \"File [$des] is in use\"}\r\n\t\t}\r\n\t\t$file=ls $des;\r\n\t\tIf(Test-Path ($file.DirectoryName+\"/\"+$file.basename+\"_end\")){Return Ret-Success \"Download-File:No Need Operator\"}\r\n\t}\r\n\tTry{\r\n\t\t$web=New-Object System.Net.WebClient;\r\n\t\t$web.Encoding=[System.Text.Encoding]::UTF8;\r\n\t\t$web.DownloadFile(\"$src\", \"$des\");\r\n\t\t$file=(ls $des);\r\n\t\t$endFile=$file.basename+\"_end\";\r\n\t\tNew-Item -Path $file.DirectoryName -Name $endFile -ItemType \"file\" |Out-Null\r\n\t\tIf(!(Test-Path $des) -or (Get-Content \"$des\" -totalcount 1) -eq $null){Return \"BusinessException:The downloaded file does not exist or the content is empty\"}\r\n\t}Catch{Return Print-Exception \"$web.DownloadFile($src,$des)\"}\r\n\tReturn Ret-Success \"Download-File\"\r\n}",
  "callContent" : "",
  "subNames" : ["Ret-Success", "Test-FileLocked", "Print-Exception"],
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})

db.psScriptTemplate.remove({name:"Set-Processd"});
db.psScriptTemplate.save({
  "_id" : ObjectId("5e6f385fa0ff38f9cc08b6ba"),
  "name" : "Set-Processd",
  "desc" : "进程操作",
  "content" : "Function Set-Processd([String]$processName,[bool]$isRun,[String]$startFile,[bool]$isClear=$false){\r\n\t$business=\"[Set-Processd $processName]=>>\"\r\n\tIf([String]::isNullOrEmpty($processName)){\r\n\t\tReturn \"${business}BusinessException:processName can not empty\"\r\n\t}\r\n\t$pro=Get-Process $processName;\r\n\tIf($isRun){\r\n\t\tIf($pro -ne $null){\r\n\t\t\tReturn \"${business}No Need Operator%%SMP:success\"\r\n\t\t}\r\n\t\tIf([String]::isNullOrEmpty($startFile)){\r\n\t\t\tReturn \"${business}BusinessException:To start a process, The process startFile cannot be empty\";\t\r\n\t\t}\r\n\t\t\r\n\t\tIf(!(Test-Path $startFile)){\r\n\t\t\tReturn \"${business}BusinessException:[$startFile] does not exist,cannot start process\"\r\n\t\t}\r\n\t\t\r\n\t\tStart-Process $startFile;\r\n\t\tIf(!$?){Return Print-Exception \"${business}Start-Process $startFile\"}\r\n\t\tReturn Ret-Success $business\r\n\t}Else{\r\n\t\tIf($pro -eq $null){\r\n\t\t\tIf($isClear){\r\n\t\t\t\tIf([String]::isNullOrEmpty($startFile)){\r\n\t\t\t\t\tReturn \"${business}BusinessException:To clean up a process, The process startFile cannot be empty\";\t\r\n\t\t\t\t}\r\n\t\t\t\tRemove-Item -Force $startFile;\r\n\t\t\t\tIf(!$?){Return Print-Exception \"${business}Remove-Item -Force $startFile\"}\r\n\t\t\t}\r\n\t\t\tReturn \"${business}No Need Operator%%SMP:success\"\r\n\t\t}\r\n\t\t\r\n\t\t$pro|Foreach{\r\n\t\t\tStop-Process $_.Id -Force;\r\n\t\t\tIf(!$?){Return Print-Exception \"Stop-Process $_.Id -Force\"}\r\n\t\t}\r\n\t\tSleep 1;\r\n\t\t\r\n\t\t$pro=Get-Process $processName;\t\r\n\t\tIf($pro -ne $null){\r\n\t\t\tReturn \"${business}BusinessException:Failed to terminate process\"\r\n\t\t}\r\n\t\t\r\n\t\tIf($isClear){\r\n\t\t\tIf([String]::isNullOrEmpty($startFile)){\r\n\t\t\t\tReturn \"${business}BusinessException:To start a process, The process startFile cannot be empty\";\t\r\n\t\t\t}\r\n\t\t\t\r\n\t\t\tIf(!(Test-Path $startFile)){\r\n\t\t\t\tReturn \"${business}BusinessException:[$startFile] does not exist,cannot start process\"\r\n\t\t\t}\r\n\t\t\t\r\n\t\t\tRemove-Item -Force $startFile;\r\n\t\t\tIf(!$?){Return Print-Exception \"Remove-Item -Force $startFile\"}\r\n\t\t}\r\n\t\tReturn Ret-Success $business\r\n\t}\r\n}",
  "callContent" : "",
  "subNames" : ["Ret-Success", "Print-Exception"],
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})