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
      "name" : "~softwareVersion~",
      "defaultValue" : "$null",
      "type" : "String"
    }, {
      "name" : "~fileName64~",
      "defaultValue" : "$null",
      "type" : "String"
    }, {
      "name" : "~fileName32~",
      "defaultValue" : "$null",
	  "type" : "String"
    }, {
      "name" : "~isRun~",
      "defaultValue" : "$true",
      "type" : "Boolean"
    }, {
      "name" : "~processName~",
      "defaultValue" : "$null",
      "type" : "String"
    }],
  "analyzingContent" : "package com.ruijie.authentication.session.program.domain.program;\r\ndialect  \"java\"\r\nimport com.ruijie.authentication.session.program.domain.program.PsScriptTemplateAnalyzingProcedureFact\r\nimport com.ruijie.authentication.authnode.domain.node.compliance.ComplianceDetectingResultState\r\nrule \"classify\"\r\nwhen\r\n    fact:PsScriptTemplateAnalyzingProcedureFact()\r\nthen\r\n    if(!fact.getScriptResponse().getResponse().endsWith(\"%%SMP:success\")){\r\n        fact.setResultState(ComplianceDetectingResultState.COMPLIANCE_FAIL);\r\n        fact.setResponse(fact.getScriptResponse().getResponse());\r\n    }\r\nend",
  "content" : "Function White-Software{\r\n\tparam([String] $hostUrl,\r\n\t\t[String] $softwareName,\r\n\t\t[String] $softwareVersion,\r\n\t\t[String] $fileName64,\r\n\t\t[String] $fileName32,\r\n\t\t[bool] $isRun =$False,\r\n\t\t[String] $processName,\r\n\t\t[String] $serviceName\r\n\t);\r\n\t$business=\"[Install $softwareName]=>>\";\r\n\tIf([String]::isNullOrEmpty($softwareName)){Return \"BusinessException:softwareName can not empty\"}\r\n\tIf((Get-SoftwareInfoByNameVersion $softwareName $softwareVersion) -ne $null){\r\n\t\tIf(!$isRun){Return Ret-Success $business}\r\n\t\tIf([String]::isNullOrEmpty($serviceName) -and [String]::isNullOrEmpty($processName)){\r\n\t\t\tReturn \"BusinessException:The software needs to be opened. The process name and service name cannot both be empty\"\r\n\t\t}\r\n\t\tIf(![String]::isNullOrEmpty($serviceName)){\r\n\t\t\t$Res = Set-Serviced $serviceName 'Automatic' 'Running';\"$business$Res\";\r\n\t\t\tIf(Is-Success $Res){Return}\r\n\t\t}\r\n\t\tIf(![String]::isNullOrEmpty($processName)){\r\n\t\t\t$Res = Set-Processd $processName $true $null;\"$business$Res\";\r\n\t\t\tIf(Is-Success $Res){Return}\r\n\t\t}\r\n\t}ElseIf($softwareName -like '*guard*'){\r\n\t\t$processName='WINRDLV3'\r\n\t\t$Res = Set-Processd $processName $true \"C:\\WINDOWS\\system32\\winrdlv3.exe\";\"$business$Res\";\r\n\t\tIf(Is-Success $Res){Return}\r\n\t}\r\n\r\n\tIf([String]::isNullOrEmpty($hostUrl)){Return \"BusinessException:hostUrl can not empty\"}\r\n\tIf([String]::isNullOrEmpty($fileName64) -and [String]::isNullOrEmpty($fileName32)){Return \"BusinessException:install package can not empty\"}\r\n\r\n\t$downloadPath = Join-Path $env:SystemDrive '/Program Files/Ruijie Networks/softwarePackage/';\r\n\tIf(!(Test-Path $downloadPath)){mkdir $downloadPath -Force|Out-Null}\r\n\r\n\tIf([IntPtr]::Size -eq 8 -and ![String]::isNullOrEmpty($fileName64)){\r\n\t\t$bit='bit64';\r\n\t\t$fileName=$fileName64;\r\n\t}Else{\r\n\t\t$bit='bit32';\r\n\t\t$fileName=$fileName32\r\n\t}\r\n\r\n\t$softwarePath = Join-Path $downloadPath $fileName;\r\n\tIf(!(Test-Path \"$softwarePath\") -or (Get-Content \"$softwarePath\" -TotalCount 1) -eq $null){\r\n\t\t$tmp=Handle-SpecialCharactersOfHTTP \"?fileName=$fileName&dir=win/$bit\";\r\n\t\t$remoteSoftwarePath=$hostUrl+'/temp'+$tmp;\r\n\t\t$Res=Download-File \"$remoteSoftwarePath\" \"$softwarePath\";\"$business$Res\";\r\n\t\tIf(!(Is-Success $Res)){Return}\r\n\t}\r\n\t$Suffix=(Get-ChildItem -Path $softwarePath).Extension.substring(1);\r\n\tIf('msi' -eq $Suffix){\r\n\t\t$os=Get-WmiObject -Class Win32_OperatingSystem | Select -ExpandProperty Caption\r\n\t\tIf($os -Like '*Windows 7*' -Or $os -Like '*Windows 8*'){\r\n\t\t\tInvoke-Expression \"& cmd /c `'msiexec.exe /i `\"$softwarePath`\"`' /qn ADVANCED_OPTIONS=1 CHANNEL=100\"\r\n\t\t}Else{\r\n\t\t\tInvoke-Expression \"Msiexec /i `\"$softwarePath`\" /norestart /qn\" -ErrorAction SilentlyContinue;\r\n\t\t\tIf(!$?){Return Print-Exception \"Msiexec /i `\"$softwarePath`\" /norestart /qn\"}\r\n\t\t}\r\n\t}else{\r\n\t\t$Res=OperatorSoftwareBySWI $hostUrl $softwarePath;\"$business$Res\";\r\n\t\tIf(!(Is-Success $Res)){Return}\r\n\t}\r\n\t\r\n\tIf((Get-SoftwareInfoByNameVersion $softwareName $softwareVersion) -eq $null){Return \"BusinessException:Installation of the software has not been successful\"}\r\n\tIf($isRun){\r\n\t\tIf(![String]::isNullOrEmpty($serviceName)){\r\n\t\t\t$Res = Set-Serviced $serviceName 'Automatic' 'Running';\"$business$Res\";\r\n\t\t\tIf(!(Is-Success $Res)){Return}\r\n\t\t}\r\n\t\tIf(![String]::isNullOrEmpty($processName)){\r\n\t\t\t$Res = Set-Processd $processName $true $startFileDir;\"$business$Res\";\r\n\t\t\tIf(!(Is-Success $Res)){Return}\r\n\t\t}\r\n\t}\r\n\tReturn Ret-Success $business\r\n}",
  "callContent" : "White-Software ~hostUrl~ ~softwareName~ ~softwareVersion~ ~fileName64~ ~fileName32~ ~isRun~ ~processName~",
  "subNames" : ["Ret-Success", "Is-Success", "Print-Exception", "Download-File", "Get-SoftwareInfoByNameVersion", "Set-Serviced", "Set-Processd", "OperatorSoftwareBySWI", "Handle-SpecialCharactersOfHTTP"],
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})