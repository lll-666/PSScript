db.psScriptTemplate.remove({name:"Custom"});
db.psScriptTemplate.save({
  "_id" : ObjectId("5e717d5f91135576c890824f"),
  "name" : "Custom",
  "desc" : "自定义合规动作初始化脚本",
  "isOpen" : true,
  "params" : [],
  "analyzingContent" : "package com.ruijie.authentication.session.program.domain.program;\r\ndialect  \"java\"\r\nimport com.ruijie.authentication.session.program.domain.program.PsScriptTemplateAnalyzingProcedureFact\r\nimport com.ruijie.authentication.authnode.domain.node.compliance.ComplianceDetectingResultState\r\nrule \"analyzingResult\"\r\nwhen\r\n    fact:PsScriptTemplateAnalyzingProcedureFact()\r\nthen\r\n    String response = fact.getScriptResponse().getResponse();\r\n    fact.setResponse(response);\r\n    PsScriptTemplateAnalyzingProcedureFact.AnalyzingResult analyzingResult = fact.parseObject(response);\r\n    if(!analyzingResult.isSuccess()){\r\n        fact.setResultState(ComplianceDetectingResultState.COMPLIANCE_FAIL);\r\n    }\r\nend",
  "content" : "Function Execution-Script{\r\n\tparam(\r\n\t\t[String] $param1=$null,\r\n\t\t[Bool] $param2=$True\r\n\t)\r\n\t\r\n\t<#该脚本仅为示例,中间业务部分省去#>\r\n\t\r\n\t$Result=''|select isSuccess,msg,retObj;\r\n\t$Result.isSuccess='false';\r\n\t$Result.msg='获取xxx信息失败';\r\n\t$Result.retObj=$Null;\r\n\tReturn $Result;\r\n}",
  "callContent" : "Execution-Script -param1 $null -param2 $True|%{ConvertToJson $_}",
  "subNames" : ["ConvertToJson"],
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})
db.complianceAction.remove({ name: "Open-FireWall" });
db.complianceAction.save({
  "_id": ObjectId("5e68a83e5448f58c7445143a"),
  "connectorCategoryEnum" : "PS_NODE",
  "category" : NumberInt(11),
  "name" : "Open-FireWall",
  "templateName" : "Set-FireWallState",
  "desc" : "合规动作-开启防火墙",
  "isTip" : true,
  "tipMessage" : "请开启防火墙",
  "script" : "Function Get-FireWallState{\r\n\tparam(\r\n\t\t[ValidateSet('domainprofile','privateprofile','publicprofile')][String]$profile\r\n\t);\r\n\t$matchs=@((UnicodeToChinese '\\u542f\\u7528'),(UnicodeToChinese '\\u6253\\u5f00'),'on','open','enable');\r\n\t$content =(netsh advfirewall show $profile state|Select -Skip 3 -First 1).ToLower();\r\n\tForeach($match In $matchs){\r\n\t\tIf($content.Contains($match)){\r\n\t\t\tReturn $true;\r\n\t\t}\r\n\t}$false\r\n}Function Set-FireWallState{\r\n\tparam(\r\n\t\t[ValidateSet('off','on','notconfigured')]\r\n\t\t[String]$state\r\n\t);\r\n\tFunction IsSucc([Object[]] $str){\r\n\t\t$st=$str[-1].trim();\r\n\t\t$st=$st.subString(0,$st.Length-1).ToLower();\r\n\t\tReturn ($st.EndsWith((UnicodeToChinese '\\u786e\\u5b9a')) -Or $st.EndsWith('ok'))\r\n\t}\r\n\tIf((Get-Service mpssvc).Status -ne 'Running'){Set-Service mpssvc -StartupType Automatic;Start-Service mpssvc;}\r\n\tForeach($profile In 'domainprofile','privateprofile','publicprofile'){\r\n\t\t$enable=Get-FireWallState $profile\r\n\t\tIf((!$enable -And 'on' -eq $state) -Or ($enable -And 'off' -eq $state)){\r\n\t\t\t$tmp=(netsh advfirewall set $profile state $state)|select -First 3|WHere{![String]::isNullOrEmpty($_)}\r\n\t\t\tIf(IsSucc $tmp){\r\n\t\t\t\t$res=\"Set $profile $state,%%SMP:executing-suffice;\"+$res\r\n\t\t\t}Else{\r\n\t\t\t\t$res+=\"Set $profile $state,%%SMP:executing-fail;\"\r\n\t\t\t}\r\n\t\t}Else{\r\n\t\t\t$res=\"Set $profile $state,%%SMP:detecting-suffice;\"+$res\r\n\t\t}\r\n\t}\r\n\tReturn $res.substring(0,$res.Length-1);\r\n}\r\nFunction UnicodeToChinese([String]$sourceStr){\r\n\t[regex]::Replace($sourceStr,'\\\\u[0-9-a-f]{4}',{param($v);[char][int]($v.Value.replace('\\u','0x'))})\r\n}\r\nSet-FireWallState on",
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class": "com.ruijie.authentication.authnode.domain.compliance.ComplianceAction"
});
db.complianceAction.remove({ name: "Close-FireWall" });
db.complianceAction.save({
  "_id": ObjectId("5e845465911355b228adc833"),
  "connectorCategoryEnum" : "PS_NODE",
  "category" : NumberInt(11),
  "name" : "Close-FireWall",
  "templateName" : "Set-FireWallState",
  "desc" : "合规动作-关闭防火墙",
  "isTip" : true,
  "tipMessage" : "请开关闭防火墙",
  "script" : "Function Get-FireWallState{\r\n\tparam(\r\n\t\t[ValidateSet('domainprofile','privateprofile','publicprofile')][String]$profile\r\n\t);\r\n\t$matchs=@((UnicodeToChinese '\\u542f\\u7528'),(UnicodeToChinese '\\u6253\\u5f00'),'on','open','enable');\r\n\t$content =(netsh advfirewall show $profile state|Select -Skip 3 -First 1).ToLower();\r\n\tForeach($match In $matchs){\r\n\t\tIf($content.Contains($match)){\r\n\t\t\tReturn $true;\r\n\t\t}\r\n\t}$false\r\n}Function Set-FireWallState{\r\n\tparam(\r\n\t\t[ValidateSet('off','on','notconfigured')]\r\n\t\t[String]$state\r\n\t);\r\n\tFunction IsSucc([Object[]] $str){\r\n\t\t$st=$str[-1].trim();\r\n\t\t$st=$st.subString(0,$st.Length-1).ToLower();\r\n\t\tReturn ($st.EndsWith((UnicodeToChinese '\\u786e\\u5b9a')) -Or $st.EndsWith('ok'))\r\n\t}\r\n\tIf((Get-Service mpssvc).Status -ne 'Running'){Set-Service mpssvc -StartupType Automatic;Start-Service mpssvc;}\r\n\tForeach($profile In 'domainprofile','privateprofile','publicprofile'){\r\n\t\t$enable=Get-FireWallState $profile\r\n\t\tIf((!$enable -And 'on' -eq $state) -Or ($enable -And 'off' -eq $state)){\r\n\t\t\t$tmp=(netsh advfirewall set $profile state $state)|select -First 3|WHere{![String]::isNullOrEmpty($_)}\r\n\t\t\tIf(IsSucc $tmp){\r\n\t\t\t\t$res=\"Set $profile $state,%%SMP:executing-suffice;\"+$res\r\n\t\t\t}Else{\r\n\t\t\t\t$res+=\"Set $profile $state,%%SMP:executing-fail;\"\r\n\t\t\t}\r\n\t\t}Else{\r\n\t\t\t$res=\"Set $profile $state,%%SMP:detecting-suffice;\"+$res\r\n\t\t}\r\n\t}\r\n\tReturn $res.substring(0,$res.Length-1);\r\n}\r\nFunction UnicodeToChinese([String]$sourceStr){\r\n\t[regex]::Replace($sourceStr,'\\\\u[0-9-a-f]{4}',{param($v);[char][int]($v.Value.replace('\\u','0x'))})\r\n}\r\nSet-FireWallState off",
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class": "com.ruijie.authentication.authnode.domain.compliance.ComplianceAction"
});
/*合规动作初始化脚本--end*/

/*PowerShell脚本模板--start*/
db.psScriptTemplate.remove({ name: "Get-FireWallState" });
db.psScriptTemplate.save({
  "_id" : ObjectId("5e844acf911355b228adc828"),
  "name" : "Get-FireWallState",
  "desc" : "获取防火墙状态",
  "params" : [{
      "name" : "~profile~",
      "defaultValue" : "$null",
      "type" : "String"
    }],
  "isOpen" : true,
  "content" : "Function Get-FireWallState{\r\n\tparam(\r\n\t\t[ValidateSet('domainprofile','privateprofile','publicprofile')][String]$profile\r\n\t);\r\n\t$matchs=@((UnicodeToChinese '\\u542f\\u7528'),(UnicodeToChinese '\\u6253\\u5f00'),'on','open','enable');\r\n\t$content =(netsh advfirewall show $profile state|Select -Skip 3 -First 1).ToLower();\r\n\tForeach($match In $matchs){\r\n\t\tIf($content.Contains($match)){\r\n\t\t\tReturn $true;\r\n\t\t}\r\n\t}$false\r\n}",
  "callContent" : "Get-FireWallState ~profile~",
  "subNames" : ["UnicodeToChinese"],
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class": "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
});

db.psScriptTemplate.remove({ name: "UnicodeToChinese" });
db.psScriptTemplate.save({
  "_id" : ObjectId("5e8f3b579113553f30a57143"),
  "name" : "UnicodeToChinese",
  "desc" : "unicode转中文",
  "params" : [{
      "name" : "~sourceStr~",
      "defaultValue" : "",
      "type" : "String"
    }],
  "isOpen" : true,
  "content" : "Function UnicodeToChinese([String]$sourceStr){\r\n\t[regex]::Replace($sourceStr,'\\\\u[0-9-a-f]{4}',{param($v);[char][int]($v.Value.replace('\\u','0x'))})\r\n}",
  "callContent" : "UnicodeToChinese ~sourceStr~",
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class": "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
});

db.psScriptTemplate.remove({name:"Set-FireWallState"});
db.psScriptTemplate.save({
  "_id" : ObjectId("5e844b97911355b228adc829"),
  "name" : "Set-FireWallState",
  "desc" : "开启或关闭防火墙",
  "params" : [{
      "name" : "~state~",
      "defaultValue" : "$null",
      "type" : "String"
    }],
  "isOpen" : true,
  "content" : "Function Set-FireWallState{\r\n\tparam(\r\n\t\t[ValidateSet('off','on','notconfigured')]\r\n\t\t[String]$state\r\n\t);\r\n\tFunction IsSucc([Object[]] $str){\r\n\t\t$st=$str[-1].trim();\r\n\t\t$st=$st.subString(0,$st.Length-1).ToLower();\r\n\t\tReturn ($st.EndsWith((UnicodeToChinese '\\u786e\\u5b9a')) -Or $st.EndsWith('ok'))\r\n\t}\r\n\tIf((Get-Service mpssvc).Status -ne 'Running'){Set-Service mpssvc -StartupType Automatic;Start-Service mpssvc;}\r\n\tForeach($profile In 'domainprofile','privateprofile','publicprofile'){\r\n\t\t$enable=Get-FireWallState $profile\r\n\t\tIf((!$enable -And 'on' -eq $state) -Or ($enable -And 'off' -eq $state)){\r\n\t\t\t$tmp=(netsh advfirewall set $profile state $state)|select -First 3|WHere{![String]::isNullOrEmpty($_)}\r\n\t\t\tIf(IsSucc $tmp){\r\n\t\t\t\t$res=\"Set $profile $state,%%SMP:executing-suffice;\"+$res\r\n\t\t\t}Else{\r\n\t\t\t\t$res+=\"Set $profile $state,%%SMP:executing-fail;\"\r\n\t\t\t}\r\n\t\t}Else{\r\n\t\t\t$res=\"Set $profile $state,%%SMP:detecting-suffice;\"+$res\r\n\t\t}\r\n\t}\r\n\tReturn $res.substring(0,$res.Length-1);\r\n}",
  "callContent" : "Set-FireWallState ~state~",
  "analyzingContent" : "package pstemplates.openfirewall;\r\ndialect  \"mvel\"\r\n\r\nimport com.ruijie.authentication.session.program.domain.program.PsScriptTemplateAnalyzingProcedureFact;\r\nimport com.ruijie.authentication.authnode.domain.node.LabelValue;\r\nimport com.ruijie.authentication.authnode.domain.node.compliance.ComplianceDetectingResultState;\r\nimport com.ruijie.authentication.authnode.domain.label.LabelConstant;\r\n\r\nrule \"analyzingScript\"\r\n    when\r\n        $fact: PsScriptTemplateAnalyzingProcedureFact($node: node, $scriptResponse: scriptResponse, $labels: updateLabels)\r\n    then\r\n        if ($scriptResponse.isError() || $scriptResponse.isTimeout()){\r\n            $fact.setResultState(ComplianceDetectingResultState.EXCEPTION_SUFFICE);\r\n            $fact.setOperateRecord(\"执行异常或执行操作，默认合规\");\r\n        } else {\r\n           String response = $scriptResponse.getResponse();\r\n           String result = response.substring(response.indexOf(\"%%SMP:\") + 6);\r\n           if (\"detecting-suffice\".equals(result) || \"executing-suffice\".equals(result)){\r\n                $labels.put(LabelConstant.FIRE_WALL_ALL_ON, LabelValue.builder()\r\n                                        .value(true)\r\n                                        .build());\r\n                $fact.setResultState(ComplianceDetectingResultState.COMPLIANCE_SUFFICE);\r\n                $fact.setOperateRecord(\"防火墙已开启！\");\r\n           }else if(\"executing-fail\".equals(result)){\r\n                $labels.put(LabelConstant.FIRE_WALL_ALL_ON, LabelValue.builder()\r\n                                        .value(false)\r\n                                        .build());\r\n                $fact.setResultState(ComplianceDetectingResultState.COMPLIANCE_FAIL);\r\n                $fact.setOperateRecord(\"防火墙开启失败！\");\r\n           } else {\r\n                $labels.put(LabelConstant.FIRE_WALL_ALL_ON, LabelValue.builder()\r\n                                                       .value(true)\r\n                                                       .build());\r\n                $fact.setResultState(ComplianceDetectingResultState.COMPLIANCE_SUFFICE);\r\n                $fact.setOperateRecord(\"内部异常，默认合规！\");\r\n           }\r\n        }\r\nend\r\n",
  "subNames" : ["Get-FireWallState", "UnicodeToChinese"],
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})

db.psScriptTemplate.remove({name:"Dangerous-Port"});
db.psScriptTemplate.save({
  "_id" : ObjectId("5e68a7fc5448f543905f4beb"),
  "name" : "Dangerous-Port",
  "desc" : "高危端口",
  "params" : [{
      "name" : "~port~",
      "defaultValue" : "$null",
      "type" : "int"
    }, {
      "name" : "~protocol~",
      "defaultValue" : "TCP",
      "type" : "String"
    }, {
      "name" : "~action~",
      "defaultValue" : "$null",
      "type" : "String"
    }],
  "isOpen" : true,
  "content" : "Function Dangerous-Port{\r\n\tparam(\r\n\t\t[int] $port,\r\n\t\t[String] $protocol,\r\n\t\t[ValidateSet('allow','block')][String] $action\r\n\t)\r\n\tFunction IsSucc([Object[]] $str){\r\n\t\t$st=$str[-1].trim();\r\n\t\t$st=$st.subString(0,$st.Length-1).ToLower();\r\n\t\tReturn ($st.EndsWith((UnicodeToChinese '\\u786e\\u5b9a')) -Or $st.EndsWith('ok'))\r\n\t}\r\n\tIf((Get-Service mpssvc).Status -ne 'Running'){Set-Service mpssvc -StartupType Automatic;Start-Service mpssvc;}\r\n\tForeach($tmp In @('allow','block')){\r\n\t\t$ruleName=\"SmpPlus-${protocol}-${port}-${tmp}\";\r\n\t\t$res=netsh advfirewall firewall show rule name=$ruleName;\r\n\t\tIf($res.Count -gt 3){\r\n\t\t\tIf($tmp -eq $action){Return \"%%SMP:detecting-suffice\"}\r\n\t\t\t$del=(netsh advfirewall firewall delete rule name=$ruleName)|select -First 3|WHere{![String]::isNullOrEmpty($_)}\r\n\t\t\tIf(!(IsSucc $del)){Return (${del}+=\"%%SMP:executing-fail\")}\r\n\t\t\tBreak;\r\n\t\t}\r\n\t}\r\n\t$ruleName=\"SmpPlus-${protocol}-${port}-${action}\"\r\n\t$add=(netsh advfirewall firewall add rule name=$ruleName profile=any dir=out protocol=$protocol localport=$port action=$action)|select -First 3|WHere{![String]::isNullOrEmpty($_)}\r\n\t$del+=$add\r\n\tIf(IsSucc $add){\r\n\t\tReturn ${del}+=\"%%SMP:executing-suffice\"\r\n\t}Else{\r\n\t\tReturn ${del}+=\"%%SMP:executing-fail\"\r\n\t}\r\n}",
  "callContent" : "Dangerous-Port ~port~ ~protocol~ ~action~",
  "analyzingContent" : "package pstemplates.dangerousport;\r\ndialect  \"mvel\"\r\n\r\nimport com.ruijie.authentication.session.program.domain.program.PsScriptTemplateAnalyzingProcedureFact;\r\nimport com.ruijie.authentication.authnode.domain.node.LabelValue;\r\nimport com.ruijie.authentication.authnode.domain.node.compliance.ComplianceDetectingResultState;\r\nimport com.ruijie.authentication.authnode.domain.label.LabelConstant;\r\n\r\nrule \"analyzingScript\"\r\n    when\r\n        $fact: PsScriptTemplateAnalyzingProcedureFact($node: node, $scriptResponse: scriptResponse, $labels: updateLabels)\r\n    then\r\n        if ($scriptResponse.isError() || $scriptResponse.isTimeout()){\r\n            $fact.setResultState(ComplianceDetectingResultState.EXCEPTION_SUFFICE);\r\n            $fact.setOperateRecord(\"执行异常或执行操作，默认合规\");\r\n        } else {\r\n            String response = $scriptResponse.getResponse();\r\n            String result = response.substring(response.indexOf(\"%%SMP:\") + 6);\r\n            String resultInfo = response.substring(response.indexOf(\"%%RESULT:\") + 9);\r\n\r\n            if (result.contains(\"detecting-suffice\") || result.contains(\"executing-suffice\")){\r\n                 $fact.setResultState(ComplianceDetectingResultState.COMPLIANCE_SUFFICE);\r\n                 $fact.setOperateRecord(\"端口\" + resultInfo + \"已禁用！\");\r\n            }else if(result.contains(\"executing-fail\")){\r\n                 $fact.setResultState(ComplianceDetectingResultState.COMPLIANCE_FAIL);\r\n                 $fact.setOperateRecord(\"端口\" + resultInfo + \"禁用失败！\");\r\n            } else {\r\n                 $fact.setResultState(ComplianceDetectingResultState.COMPLIANCE_SUFFICE);\r\n                 $fact.setOperateRecord(\"内部异常，默认合规！\");\r\n            }\r\n        }\r\nend",
  "subNames" : [],
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})