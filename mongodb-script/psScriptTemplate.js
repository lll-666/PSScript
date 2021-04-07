var mongo = db.getMongo();
var db = mongo.getDB('nodes');

/*合规动作初始化脚本--start*/
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
  "analyzingContent" : "package pstemplates.openfirewall;\r\ndialect  \"java\"\r\nimport java.util.regex.Pattern;\r\nimport com.ruijie.authentication.session.program.domain.program.PsScriptTemplateAnalyzingProcedureFact;\r\nimport com.ruijie.authentication.authnode.domain.node.LabelValue;\r\nimport com.ruijie.authentication.authnode.domain.node.compliance.ComplianceDetectingResultState;\r\nimport com.ruijie.authentication.authnode.domain.label.LabelConstant;\r\nrule \"analyzingScript\"\r\n    when\r\n        $fact: PsScriptTemplateAnalyzingProcedureFact($node: node, $scriptResponse: scriptResponse, $labels: updateLabels)\r\n    then\r\n        if ($scriptResponse.isError() || $scriptResponse.isTimeout()){\r\n            $fact.setResultState(ComplianceDetectingResultState.EXCEPTION_SUFFICE);\r\n            $fact.setOperateRecord(\"执行异常或执行操作，默认合规\");\r\n        } else {\r\n           String response = $scriptResponse.getResponse();\r\n           if(Pattern.matches(\".*executing-fail.*\", response)){\r\n                $labels.put(LabelConstant.FIRE_WALL_ALL_ON, LabelValue.builder().value(false).build());\r\n                $fact.setResultState(ComplianceDetectingResultState.COMPLIANCE_FAIL);\r\n                $fact.setOperateRecord(\"防火墙开启失败！\");\r\n           }else if (Pattern.matches(\".*detecting-suffice.*\", response) || Pattern.matches(\".*executing-suffice.*\", response)){\r\n                $labels.put(LabelConstant.FIRE_WALL_ALL_ON, LabelValue.builder().value(true).build());\r\n                $fact.setResultState(ComplianceDetectingResultState.COMPLIANCE_SUFFICE);\r\n                $fact.setOperateRecord(\"防火墙已开启！\");\r\n           } else {\r\n                $labels.put(LabelConstant.FIRE_WALL_ALL_ON, LabelValue.builder().value(true).build());\r\n                $fact.setResultState(ComplianceDetectingResultState.COMPLIANCE_SUFFICE);\r\n                $fact.setOperateRecord(\"内部异常，默认合规！\");\r\n           }\r\n        }\r\nend",
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
  "content" : "Function Dangerous-Port{\r\n\tparam(\r\n        [int] $port,\r\n        [String] $protocol,\r\n        [String] $action\r\n    )\r\n\tIf((Get-Service mpssvc).Status -ne 'Running'){Set-Service mpssvc -StartupType Automatic;Start-Service mpssvc;}\r\n\tIf(![String]::IsNullOrEmpty($protocol)){$protocol=$protocol.ToLower()}\r\n\t$out=@()\r\n\tForeach($tmp In @('allow','block')){\r\n\t\t$ruleName=\"SmpPlus-${protocol}-${port}-${tmp}\";\r\n\t\t$res=netsh advfirewall firewall show rule name=$ruleName;\r\n\t\tIf($res.Count -gt 3){\r\n\t\t\tIf($tmp -eq $action){Return \"Rule $ruleName already exists %%SMP:success\"}\r\n\t\t\t$del=netsh advfirewall firewall delete rule name=$ruleName;\r\n\t\t\t$del|select -First 3|%{If(![String]::IsNullOrEmpty($_)){$rea+=$_}}\r\n\t\t\tIf($del.Count -eq 2){Return  $out+=\"Failed to delete rule $ruleName,The reason is $rea\" }Else{$out+=\"delete rule $ruleName succeeded\"}\r\n\t\t\tBreak;\r\n\t\t}\r\n\t}\r\n\t$ruleName=\"SmpPlus-${protocol}-${port}-${action}\"\r\n\t$add=netsh advfirewall firewall add rule name=$ruleName profile=any dir=in protocol=$protocol localport=$port action=$action\r\n\tIf($add.Count -eq 2 -And (($suffice=$add[0].ToLower().Trim()).Equals((UnicodeToChinese '\\u786e\\u5b9a\\u3002')) -Or $suffice.Equals('ok.'))){\r\n\t\t$out+=\"Successfully added the rule named $ruleName %%SMP:success\"\r\n\t}Else{\r\n\t\t$add|select -First 3|%{If(![String]::IsNullOrEmpty($_)){$rea+=$_}}\r\n\t\t$out+=\"Failed to add rule $ruleName,The reason is $rea\"\r\n\t}\r\n\t$out\r\n}",
  "callContent" : "Unified-Return (Dangerous-Port ~port~ ~protocol~ ~action~) Dangerous-Port",
  "analyzingContent" : "package pstemplates.dangerousport;\r\ndialect  \"mvel\"\r\n\r\nimport com.ruijie.authentication.session.program.domain.program.PsScriptTemplateAnalyzingProcedureFact;\r\nimport com.ruijie.authentication.authnode.domain.node.LabelValue;\r\nimport com.ruijie.authentication.authnode.domain.node.compliance.ComplianceDetectingResultState;\r\nimport com.ruijie.authentication.authnode.domain.label.LabelConstant;\r\n\r\nrule \"analyzingScript\"\r\n    when\r\n        $fact: PsScriptTemplateAnalyzingProcedureFact($node: node, $scriptResponse: scriptResponse, $labels: updateLabels)\r\n    then\r\n        if ($scriptResponse.isError() || $scriptResponse.isTimeout()){\r\n            $fact.setResultState(ComplianceDetectingResultState.EXCEPTION_SUFFICE);\r\n            $fact.setOperateRecord(\"执行异常或执行操作，默认合规\");\r\n        } else {\r\n            String response = $scriptResponse.getResponse();\r\n            String result = response.substring(response.indexOf(\"%%SMP:\") + 6);\r\n            String resultInfo = response.substring(response.indexOf(\"%%RESULT:\") + 9);\r\n\r\n            if (result.contains(\"detecting-suffice\") || result.contains(\"executing-suffice\")){\r\n                 $fact.setResultState(ComplianceDetectingResultState.COMPLIANCE_SUFFICE);\r\n                 $fact.setOperateRecord(\"端口\" + resultInfo + \"已禁用！\");\r\n            }else if(result.contains(\"executing-fail\")){\r\n                 $fact.setResultState(ComplianceDetectingResultState.COMPLIANCE_FAIL);\r\n                 $fact.setOperateRecord(\"端口\" + resultInfo + \"禁用失败！\");\r\n            } else {\r\n                 $fact.setResultState(ComplianceDetectingResultState.COMPLIANCE_SUFFICE);\r\n                 $fact.setOperateRecord(\"内部异常，默认合规！\");\r\n            }\r\n        }\r\nend",
  "subNames" : ["UnicodeToChinese", "Unified-Return"],
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})

db.psScriptTemplate.remove({name:"Read-MessageBoxDialog"});
db.psScriptTemplate.save({
  "_id" : ObjectId("5e6c620a9113556328a97d57"),
  "name" : "Read-MessageBoxDialog",
  "desc" : "调起弹窗提示,并再次确认",
  "isOpen" : true,
  "content" : "Function Read-MessageBoxDialog{\r\n\tparam ([string]$Message,\r\n\t[string]$WindowTitle,\r\n\t[System.Windows.Forms.MessageBoxButtons]$Buttons = [System.Windows.Forms.MessageBoxButtons]::OK,\r\n\t[System.Windows.Forms.MessageBoxIcon]$Icon = [System.Windows.Forms.MessageBoxIcon]::None)\r\n\tAdd-Type -AssemblyName System.Windows.Forms\r\n\treturn [System.Windows.Forms.MessageBox]::Show($Message, $WindowTitle, $Buttons, $Icon)\r\n}",
  "callContent" : "Read-MessageBoxDialog -Message $Message -WindowTitle $WindowTitle -Buttons OKCancel -Icon Information",
  "subNames" : [],
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})

db.psScriptTemplate.remove({name:"Get-InstalledSoftware"});
db.psScriptTemplate.save({
  "_id" : ObjectId("5e6f385fa0ff38f9cc08b6b1"),
  "name" : "Get-InstalledSoftware",
  "desc" : "收集终端软件信息",
  "isOpen" : true,
  "content" : "Function Get-InstalledSoftware{\r\n\t$Key=@('Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall','SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall');\r\n\tIf([IntPtr]::Size -eq 8){\r\n\t   $Key+='SOFTWARE\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall'\r\n\t}\r\n\t$Value='DisplayName','DisplayVersion','UninstallString','InstallLocation','RegPath','EstimatedSize','InstallDate','InstallSource','Language','ModifyPath','Publisher','icon';\r\n\tForeach($_ in $Key){\r\n\t  $Hive='LocalMachine';\r\n\t  If('Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall' -ceq $_){$Hive='CurrentUser'}\r\n\t  $RegHive=[Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($Hive,$env:COMPUTERNAME);\r\n\t  $RegKey=$RegHive.OpenSubKey($_);\r\n\t  If([string]::IsNullOrEmpty($RegKey)){Continue}\r\n\t  $RegKey.GetSubKeyNames()|ForEach{\r\n\t\t$SubKey=$RegKey.OpenSubKey($_);\r\n\t\t$retVal=1|Select-Object -Property $Value;\r\n\t\tForEach($_ in $Value){\r\n\t\t\t$tmp=$subkey.GetValue($_);\r\n\t\t\tIf(![string]::IsNullOrEmpty($tmp)){\r\n\t\t\t\tIf($tmp.gettype().name -eq 'string'){\r\n\t\t\t\t\t$retVal.$_=($tmp -replace [Regex]::UnEscape('\\u0000'), '').Replace('\"','').Replace('\\','/')\r\n\t\t\t\t}Elseif($tmp.gettype().name -eq 'int32'){\r\n\t\t\t\t\t$retVal.$_=$tmp\r\n\t\t\t\t}\r\n\t\t\t}\r\n\t\t};\r\n\t\tIf(![string]::IsNullOrEmpty($SubKey.GetValue('DisplayName'))){\r\n\t\t\t$tmp=$SubKey.Name;\r\n\t\t\tIf(![string]::IsNullOrEmpty($tmp)){\r\n\t\t\t\t$retVal.RegPath=($tmp -replace [Regex]::UnEscape('\\u0000'), '').Replace('\"','').Replace('\\','/')\r\n\t\t\t}\r\n\t\t\t$retVal\r\n\t\t}\r\n\t\t$SubKey.Close()\r\n\t  };\r\n\t  $RegHive.Close()\r\n\t}\r\n}",
  "callContent" : "Get-InstalledSoftware|Sort DisplayName,DisplayVersion -Unique|ConvertTo-Csv|Select -Skip 1",
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})

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
  "analyzingContent" : "package com.ruijie.authentication.session.program.domain.program;\r\ndialect  \"java\"\r\nimport com.ruijie.authentication.session.program.domain.program.PsScriptTemplateAnalyzingProcedureFact\r\nimport com.ruijie.authentication.authnode.domain.node.compliance.ComplianceDetectingResultState\r\nrule \"compliance\"\r\nwhen\r\n\tfact:PsScriptTemplateAnalyzingProcedureFact()\r\nthen\r\n\tfact.setResponse(fact.getScriptResponse().getResponse());\r\n\tfact.setOperateRecord(fact.getScriptResponse().getResponse());\r\n\tif(fact.getScriptResponse().isTimeout()==true){\r\n\t\tfact.setResultState(ComplianceDetectingResultState.TIME_OUT);\r\n\t\tfact.setResponse(\"script execution timeout\");\r\n\t}else if(fact.getScriptResponse().getResponse().endsWith(\"%%SMP:processing\")){\r\n\t\tfact.setResultState(ComplianceDetectingResultState.COMPLYING);\r\n\t}else if(!fact.getScriptResponse().getResponse().endsWith(\"%%SMP:success\")){\r\n\t\tfact.setResultState(ComplianceDetectingResultState.COMPLIANCE_FAIL);\r\n\t}\r\nend",
  "content" : "Function White-Software{\r\n\tparam([String] $hostUrl,\r\n\t\t[String] $softwareName,\r\n\t\t[String] $softwareVersion64,\r\n\t\t[String] $fileName64,\r\n\t\t[String] $softwareVersion32,\r\n\t\t[String] $fileName32,\r\n\t\t[bool] $silent=$false\r\n\t)\r\n\tFunction Check-IPGuard{\r\n\t\tIf((ps winrdlv3 -ErrorAction SilentlyContinue) -eq $null){Return $false}\r\n\t\tIf(!(netstat -an|findstr 8235|findstr LISTENING)){Return $false}\r\n\t\tIf(!($SV=gwmi win32_service |?{$_.name -eq '.Winhlpsvr' -And $_.status -eq 'OK'}|select pathname)){Return $false}\r\n\t\tTest-Path (($SV.pathname).Replace('\"',''))\r\n\t}\r\n\tIf([String]::isNullOrEmpty($softwareName)){Return \"BusinessException:softwareName can not empty\"}\r\n\tIf([String]::isNullOrEmpty($hostUrl)){Return \"BusinessException:hostUrl can not empty\"}\r\n\tIf([String]::isNullOrEmpty($fileName64) -and [String]::isNullOrEmpty($fileName32)){Return \"BusinessException:install package can not empty\"}\r\n\t\r\n\tIf($softwareName -like '*guard*' -And (Check-IPGuard)){Return Ret-Success \"${softwareName} has been installed\"}\r\n\t\r\n\t$downloadPath = Join-Path $env:SystemDrive '/Program Files/Ruijie Networks/softwarePackage/';\r\n\tIf(!(Test-Path $downloadPath)){mkdir $downloadPath -Force|Out-Null}\r\n\tIf([IntPtr]::Size -eq 4){\r\n\t\tIf([String]::isNullOrEmpty($fileName32)){Return Ret-Success \"no installation package32 available, default and pass\"}\r\n\t\t$softwareVersion=$softwareVersion32;\r\n\t\t$bit='bit32';\r\n\t\t$fileName=$fileName32\r\n\t}Else{\r\n\t\tIf([String]::isNullOrEmpty($fileName64)){Return Ret-Success \"no installation package64 available, default and pass\"}\r\n\t\t$softwareVersion=$softwareVersion64;\r\n\t\t$bit='bit64';\r\n\t\t$fileName=$fileName64;\r\n\t}\r\n\r\n\tIf((Get-SoftwareInfoByNameVersion $softwareName $softwareVersion) -ne $null){Return Ret-Success \"${softwareName} has been installed\"}\r\n\t$softwarePath = Join-Path $downloadPath $fileName;\r\n\tIf(!(Test-Path \"$softwarePath\") -or (cat \"$softwarePath\" -TotalCount 1) -eq $null){\r\n\t\t$tmp=Handle-SpecialCharactersOfHTTP \"?fileName=$fileName&dir=win/$bit\";\r\n\t\t$remoteSoftwarePath=$hostUrl+'/temp'+$tmp;\r\n\t\t$Res=Download-File \"$remoteSoftwarePath\" \"$softwarePath\";$Res;\r\n\t\tIf(!(Is-Success $Res)){Return}\r\n\t}\r\n\t\r\n\t$file=ls $softwarePath\r\n\tIf('.msi' -eq $file.Extension){\r\n\t\t$Res=OperatorSoftwareByMSI $softwarePath $silent\r\n\t}else{\r\n\t\t$Res=OperatorSoftwareBySWI $hostUrl $softwarePath $silent\r\n\t}\r\n\tIf(!(Is-Success $Res)){Return $Res}\r\n\tIf((Get-SoftwareInfoByNameVersion $softwareName $softwareVersion) -eq $null){Return Ret-Processing \"the software has not been installed successfully\"}\r\n\tReturn Ret-Success \r\n}",
  "callContent" : "White-Software ~hostUrl~ ~softwareName~ ~softwareVersion64~ ~fileName64~ ~softwareVersion32~ ~fileName32~",
  "subNames" : ["Ret-Success", "Is-Success", "Print-Exception", "Download-File", "Get-SoftwareInfoByNameVersion", "OperatorSoftwareBySWI", "OperatorSoftwareByMSI","Handle-SpecialCharactersOfHTTP","Ret-Processing"],
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})

db.psScriptTemplate.remove({name:"Print-Exception"});
db.psScriptTemplate.save({
  "_id" : ObjectId("5e6f385fa0ff38f9cc08b6b3"),
  "name" : "Print-Exception",
  "desc" : "执行命令异常统一处理",
  "content" : "Function Print-Exception([String]$command){\r\n\tReturn \"execute Command [$command] Exception,The Exception is $($error[0])\"\r\n}",
  "callContent" : "",
  "subNames" : [],
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})

db.psScriptTemplate.remove({name:"Ret-Success"});
db.psScriptTemplate.save({
  "_id" : ObjectId("5e6f385fa0ff38f9cc08b6b4"),
  "name" : "Ret-Success",
  "desc" : "处理成功时,统一格式返回",
  "content" : "Function Ret-Success([String] $business){\r\n\tReturn \"$business%%SMP:success\"\r\n}",
  "callContent" : "",
  "subNames" : [],
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})

db.psScriptTemplate.remove({name:"Is-Success"});
db.psScriptTemplate.save({
  "_id" : ObjectId("5e6f385fa0ff38f9cc08b6b5"),
  "name" : "Is-Success",
  "desc" : "判断子调度是否成功",
  "content" : "Function Is-Success($Ret){\r\n\tIf($Ret -ne $null -And ($Ret|Select -Last 1).EndsWith('%%SMP:success')){Return $True}\r\n\tReturn $False\r\n}",
  "callContent" : "",
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
  "content" : "Function Download-File([String]$src,[String]$des,[bool]$isReplace=$false){\r\n\tIf([String]::IsNullOrEmpty($src)){Return \"Source file does not exist\"}\r\n\tIf([String]::IsNullOrEmpty($des)){Return \"Destination address cannot be empty\"}\r\n\t$res=Check-DownloadFileIsComplete $des\r\n\tIf($res.isComplete){Return Ret-Success \"Download-File:No Need Operator\"}\r\n\tif(Test-FileLocked $des){Return Ret-Processing \"File [$des] is in use\"}\r\n\tTry{\r\n\t\t$web=New-Object System.Net.WebClient\r\n\t\t$web.Encoding=[System.Text.Encoding]::UTF8\r\n\t\t$web.DownloadFile(\"$src\", \"$des\")\r\n\t\tIf(!(Test-Path $des) -or (Get-Content \"$des\" -totalcount 1) -eq $null){Return \"The downloaded file does not exist or the content is empty\"}\r\n\t\tIf([String]::IsNullOrEmpty($res.endFilePath)){$res=Check-DownloadFileIsComplete $des}\r\n\t\tNew-Item -Path $res.endFilePath -ItemType \"file\"|Out-Null\r\n\t}Catch{Return Print-Exception \"$web.DownloadFile($src,$des)\"}\r\n\tReturn Ret-Success \"Download-File\"\r\n}",
  "callContent" : "",
  "subNames" : ["Ret-Success", "Ret-Processing", "Test-FileLocked", "Print-Exception", "Check-DownloadFileIsComplete"],
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})

db.psScriptTemplate.remove({name:"Check-DownloadFileIsComplete"});
db.psScriptTemplate.save({
  "_id" : ObjectId("5f6c447c91135522fc3eaa1e"),
  "name" : "Check-DownloadFileIsComplete",
  "desc" : "检查下载文件是否完整，并返回完整标志文件",
  "content" : "Function Check-DownloadFileIsComplete($FilePath){\r\n\t$isComplete=$false\r\n\tIf(Test-Path $FilePath){\r\n\t\t$file=gi $FilePath\r\n\t\t$endFilePath=Join-Path $file.DirectoryName \"$($file.basename)_end\"\r\n\t\t$isComplete=Test-Path $endFilePath\r\n\t}\r\n\tReturn New-Object PSObject -Property @{isComplete=$isComplete;endFilePath=$endFilePath;filePath=$FilePath}\r\n}",
  "callContent" : "Check-DownloadFileIsComplete $FilePath",
  "subNames" : [],
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})

db.psScriptTemplate.remove({name:"Get-SoftwareInfoByNameVersion"});
db.psScriptTemplate.save({
  "_id" : ObjectId("5e6f385fa0ff38f9cc08b6b7"),
  "name" : "Get-SoftwareInfoByNameVersion",
  "desc" : "根据软件名称(必输)和版本(可选)获取软件信息",
  "content" : "Function Get-SoftwareInfoByNameVersion([String] $name,[String] $version){\r\n\t$Key=@('Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall','SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall');\r\n\tIf([IntPtr]::Size -eq 8){$Key+='SOFTWARE\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall'}\r\n\tForeach($_ In $Key){\r\n\t  $Hive='LocalMachine';\r\n\t  If('Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall' -ceq $_){$Hive='CurrentUser'}\r\n\t  $RegHive=[Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($Hive,$env:COMPUTERNAME);\r\n\t  $RegKey=$RegHive.OpenSubKey($_);\r\n\t  If([string]::IsNullOrEmpty($RegKey)){Continue}\r\n\t  $arrs=$RegKey.GetSubKeyNames();\r\n\t  Foreach($_ In $arrs){\r\n\t\t$SubKey=$RegKey.OpenSubKey($_);\r\n\t\t$tmp=$subkey.GetValue('DisplayName');\r\n\t\tIf(![string]::IsNullOrEmpty($tmp)){\r\n\t\t\t$tmp=$tmp.Trim();\r\n\t\t\tIf($tmp.gettype().name -eq 'string' -And $tmp -like $name){\r\n\t\t\t\t$DisplayVersion=$subkey.GetValue('DisplayVersion');\r\n\t\t\t\tIf(![string]::IsNullOrEmpty($version) -and $version -notlike $DisplayVersion){Continue}\r\n\t\t\t\t$retVal=''|Select 'DisplayName','DisplayVersion','UninstallString','InstallLocation','RegPath','InstallDate','InstallSource';\r\n\t\t\t\t$retVal.DisplayName=$subkey.GetValue('DisplayName');\r\n\t\t\t\t$retVal.DisplayVersion=$DisplayVersion;\r\n\t\t\t\t$retVal.UninstallString=$subkey.GetValue('UninstallString');\r\n\t\t\t\t$retVal.InstallLocation=$subkey.GetValue('InstallLocation');\r\n\t\t\t\t$retVal.RegPath=$subkey.GetValue('RegPath');\r\n\t\t\t\t$retVal.InstallDate=$subkey.GetValue('InstallDate');\r\n\t\t\t\t$retVal.InstallSource=$subkey.GetValue('InstallSource');\r\n\t\t\t\tReturn $retVal;\r\n\t\t\t}\r\n\t\t}\r\n\t\t$SubKey.Close()\r\n\t  };\r\n\t  $RegHive.Close()\r\n\t};\r\n}",
  "callContent" : "Get-SoftwareInfoByNameVersion $name $version",
  "subNames" : [],
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
  "content" : "Function OperatorSoftwareBySWI([String]$hostUrl,[String]$softwarePath,$isSilent=$false,$param){\r\n\tIf([String]::IsNullOrEmpty(\"$softwarePath\")){\r\n\t\tReturn \"Executable file [${softwarePath}] does not exist\"\r\n\t}\r\n\tIf($softwarePath.StartsWith('\"')){$softwarePath=$softwarePath.substring(1,$softwarePath.LastIndexOf('\"')-1).trim()}\r\n\tIf(!$softwarePath.EndsWith(\".exe\") -And !$softwarePath.EndsWith(\".exe`\"\")){\r\n\t\tReturn \"Executable file path format error [$softwarePath]\"\r\n\t}\r\n\t\r\n\t$business=\"OperatorSoftwareBySWI of `\"$softwarePath`\"\"\r\n\t$SWIDir=Join-Path $env:SystemRoot 'System32'\r\n\tIf(!(Test-Path $SWIDir)){\r\n\t\tmkdir $SWIDir -Force|Out-Null\r\n\t\tIf(!$?){Return Print-Exception \"${business}mkdir $SWIDir -Force|Out-Null\"}\r\n\t}\r\n\t\r\n\t$Res=Check-Processing $softwarePath\r\n\tIf(!(Is-Success $Res)){Return $Res}\r\n\t\r\n\tIf([IntPtr]::Size -eq 8){$SWIFileName='SWIService64.exe'}Else{$SWIFileName='SWIService.exe'}\r\n\t$SWIPath=Join-Path $SWIDir $SWIFileName\r\n\tIf(!(Check-DownloadFileIsComplete $SWIPath).isComplete){\r\n\t\tIf([String]::IsNullOrEmpty($hostUrl)){Return \"when downloading the installation package, the host address cannot be empty\"}\r\n\t\t$remoteexePath=\"$hostUrl/$SWIFileName\"\r\n\t\t$Res=Download-File \"$remoteexePath\" \"$SWIPath\"\r\n\t\tIf(!(Is-Success $Res)){Return $Res}\r\n\t}\r\n\t\r\n\tIf($isSilent){If([String]::IsNullOrEmpty($param)){$param='/quiet /norestart /s'}}Else{$param=$null}\r\n\t$SWIServiceName='SWIserv';\r\n\tRestart-Service $SWIServiceName -ErrorAction SilentlyContinue\r\n\tIf(!$?){\r\n\t\tTry{\r\n\t\t\tIf((gsv $SWIServiceName -ErrorAction SilentlyContinue) -ne $null){sc.exe delete $SWIServiceName}\r\n\t\t\tcd $SWIDir;\r\n\t\t\tiex \".\\$SWIFileName -install -ErrorAction Stop\"\r\n\t\t}Catch{\r\n\t\t\tPrint-Exception \"${business}Restart-Service $SWIServiceName\"\r\n\t\t\tIf($param){start $softwarePath -ArgumentList @($param) -ErrorAction SilentlyContinue}Else{start $softwarePath -ErrorAction SilentlyContinue}\r\n\t\t\tIf(!$?){Return Print-Exception \"start $softwarePath -ArgumentList @($param)\"}Else{Ret-Success $business}\r\n\t\t}\r\n\t}\r\n\t \r\n\tspsv $SWIServiceName -ErrorAction SilentlyContinue;\r\n\tIf(!$?){Return Print-Exception \"${business}spsv $SWIServiceName\"}\r\n\t\r\n\tTry{\r\n\t\tWhile($sv=gsv $SWIServiceName -ErrorAction SilentlyContinue){\r\n\t\t\tIf($sv.status -eq 'Running'){sleep -Milliseconds 200;Continue}\r\n\t\t\t$sv.Start(\"{`\"exe`\":`\"$softwarePath`\",`\"arg`\":`\"$param`\"}\");Break\r\n\t\t}\r\n\t}Catch{\r\n\t\tReturn Print-Exception \"${business}(gsv $SWIServiceName).Start(\"+'\"{`\"exe`\":'+\"$softwarePath\"+',`\"arg`\":`\"/s`\"}\")'\r\n\t}\r\n\tReturn Ret-Success $business\r\n}",
  "callContent" : "OperatorSoftwareBySWI $hostUrl $softwarePath $isSilent",
  "subNames" : ["Ret-Success", "Is-Success", "Check-Processing", "Print-Exception", "Download-File","Check-DownloadFileIsComplete"],
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})

db.psScriptTemplate.remove({name:"Set-Serviced"});
db.psScriptTemplate.save({
  "_id" : ObjectId("5e6f385fa0ff38f9cc08b6b9"),
  "name" : "Set-Serviced",
  "desc" : "服务操作",
  "content" : "Function Set-Serviced([String]$serviceName,[String]$startType,[String]$status){\r\n\t$business=\"[Set-Serviced $serviceName]=>>\"\r\n\tIf([String]::IsNullOrEmpty($serviceName)){Return \"$business The serviceName can not empty\"}\r\n\t$service=Get-Service $serviceName -ErrorAction SilentlyContinue;\r\n\tIf(!$?){\r\n\t\tIf($error[0].ToString() -like '*Cannot find any service*'){\r\n\t\t\tIf('Stopped' -eq $status){Return \"Cannot find any service with service name ${serviceName} %%SMP:success\"}\r\n\t\t}\r\n\t\tReturn Print-Exception \"${business}Get-Service $serviceName\"\r\n\t}\r\n\t#StartupType:[Boot|System|Automatic|Manual|Disabled],Status:[Running|Stopped|Paused]\r\n\tif(![String]::IsNullOrEmpty($startType) -And $service.StartType -ne $startType){\r\n\t\tSet-Service $serviceName -StartupType $startType -ErrorAction SilentlyContinue;\r\n\t}\r\n\tIf(![String]::IsNullOrEmpty($status) -And $service.status -ne $status){\r\n\t\tIf('Running' -eq $service.status){\r\n\t\t\tStop-Service $serviceName -Force -ErrorAction SilentlyContinue;\r\n\t\t\tIf(!$?){Return Print-Exception \"Stop-Service $serviceName -Force\"}\r\n\t\t}Else{\r\n\t\t\tStart-Service $serviceName -ErrorAction SilentlyContinue;\r\n\t\t\tIf(!$?){Return Print-Exception \"Start-Service $serviceName\"}\r\n\t\t}\r\n\t}\r\n\tReturn Ret-Success $business\r\n}",
  "callContent" : "Set-Serviced $serviceName $startType $status",
  "subNames" : ["Ret-Success", "Print-Exception"],
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
  "content" : "Function Set-Processd([String]$processName,[bool]$isRun,[String]$startFile,[bool]$isClear=$false){\r\n\t$business=\"[Set-Processd $processName]=>>\"\r\n\tIf([String]::isNullOrEmpty($processName)){\r\n\t\tReturn \"${business}BusinessException:processName can not empty\"\r\n\t}\r\n\t$pro=Get-Process $processName -ErrorAction SilentlyContinue\r\n\tIf($isRun){\r\n\t\tIf($pro -ne $null){\r\n\t\t\tReturn \"${business}No Need Operator%%SMP:success\"\r\n\t\t}\r\n\t\tIf([String]::isNullOrEmpty($startFile)){\r\n\t\t\tReturn \"${business}BusinessException:To start a process, The process startFile cannot be empty\"\r\n\t\t}\r\n\t\t\r\n\t\tIf(!(Test-Path $startFile)){\r\n\t\t\tReturn \"${business}BusinessException:[$startFile] does not exist,cannot start process\"\r\n\t\t}\r\n\t\t\r\n\t\tStart-Process $startFile\r\n\t\tIf(!$?){Return Print-Exception \"${business}Start-Process $startFile\"}\r\n\t\tReturn Ret-Success $business\r\n\t}Else{\r\n\t\tIf($pro -eq $null){\r\n\t\t\tIf($isClear){\r\n\t\t\t\tIf([String]::isNullOrEmpty($startFile)){\r\n\t\t\t\t\tReturn \"${business}BusinessException:To clean up a process, The process startFile cannot be empty\"\r\n\t\t\t\t}\r\n\t\t\t\trm -Force $startFile -ErrorAction SilentlyContinue\r\n\t\t\t\tIf(!$?){Return Print-Exception \"${business}rm -Force $startFile\"}\r\n\t\t\t}\r\n\t\t\tReturn \"${business}No Need Operator%%SMP:success\"\r\n\t\t}\r\n\t\t\r\n\t\t$pro|Foreach{\r\n\t\t\tStop-Process $_.Id -Force -ErrorAction SilentlyContinue\r\n\t\t\tIf(!$?){Return Print-Exception \"Stop-Process $_.Id -Force\"}\r\n\t\t}\r\n\t\tSleep 1\r\n\t\t$pro=Get-Process $processName -ErrorAction SilentlyContinue\r\n\t\tIf($pro -ne $null){\r\n\t\t\tReturn \"${business}BusinessException:Failed to terminate process\"\r\n\t\t}\r\n\t\t\r\n\t\tIf($isClear){\r\n\t\t\tIf([String]::isNullOrEmpty($startFile)){\r\n\t\t\t\tReturn \"${business}BusinessException:To start a process, The process startFile cannot be empty\"\r\n\t\t\t}\r\n\t\t\t\r\n\t\t\tIf(!(Test-Path $startFile)){\r\n\t\t\t\tReturn \"${business}BusinessException:[$startFile] does not exist,cannot start process\"\r\n\t\t\t}\r\n\t\t\t\r\n\t\t\trm -Force $startFile -ErrorAction SilentlyContinue\r\n\t\t\tIf(!$?){Return Print-Exception \"rm -Force $startFile\"}\r\n\t\t}\r\n\t\tReturn Ret-Success $business\r\n\t}\r\n}",
  "callContent" : "",
  "subNames" : ["Ret-Success", "Print-Exception"],
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})

db.psScriptTemplate.remove({name:"Black-SoftwareArr"});
db.psScriptTemplate.save({
  "_id" : ObjectId("5e6f385fa0ff38f9cc08b6bb"),
  "name" : "Black-SoftwareArr",
  "desc" : "批量卸载黑名单软件",
  "params" : [{
      "name" : "~softwareList~",
      "defaultValue" : "$null",
      "type" : "Array"
    }],
  "content" : "Function Black-SoftwareArr($blackList){\r\n\t$suc=0;\r\n\t$res=1|Select success,sum,logs;\r\n\t$blackList|ConvertFrom-Csv|Foreach{\r\n\t\t$ret=Black-Software $_.hostUrl $_.softwareName $_.softwareVersion ('True' -eq $_.isAuto) $_.processName $_.serviceName;$res.logs+=\"<<$_ :\"+$ret+'>>';\r\n\t\tIf(Is-Success $ret){$suc+=1}\r\n\t}\r\n\t$res.success=$suc;\r\n\t$res.sum=$blackList.length-1;\r\n\t$tt=ConvertTo-Csv $res|Select -Skip 1\r\n\tReturn $tt\r\n}",
  "callContent" : "Black-SoftwareArr @(\"hostUrl,softwareName,softwareVersion,isAuto,processName,serviceName\", ~softwareList~);",
  "analyzingContent" : "package com.ruijie.authentication.session.program.domain.program;\r\ndialect \"java\"\r\nimport com.ruijie.authentication.session.program.domain.program.PsScriptTemplateAnalyzingProcedureFact\r\nimport com.ruijie.authentication.authnode.domain.node.compliance.ComplianceDetectingResultState\r\nimport com.ruijie.common.utils.CsvUtil\r\nimport java.util.List\r\nrule \"compliance\"\r\nwhen\r\n\tfact:PsScriptTemplateAnalyzingProcedureFact()\r\nthen\r\n\tString response = fact.getScriptResponse().getResponse();\r\n\tfact.setResponse(response);\r\n\tfact.setOperateRecord(response);\r\n\tif(fact.getScriptResponse().isTimeout()==true){\r\n\t\tfact.setResultState(ComplianceDetectingResultState.TIME_OUT);\r\n\t\tfact.setResponse(\"script execution timeout\");\r\n\t}else if(response.contains(\"%%SMP:processing\")){\r\n\t\tfact.setResultState(ComplianceDetectingResultState.COMPLYING);\r\n\t}else{\r\n\t\tList<PsBatchResult> csvData=CsvUtil.getCsvData(response, PsBatchResult.class);\r\n\t\tif(!csvData.isEmpty()){\r\n\t\t\tPsBatchResult psRetResult=csvData.get(0);\r\n\t\t\tif(psRetResult.getSuccess()!=psRetResult.getSum()){\r\n\t\t\t\tfact.setResultState(ComplianceDetectingResultState.COMPLIANCE_FAIL);\r\n\t\t\t}\r\n\t\t}\r\n\t}\r\nend",
  "subNames" : ["Black-Software"],
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})

db.psScriptTemplate.remove({name:"Black-Software"});
db.psScriptTemplate.save({
  "_id" : ObjectId("5e6f385fa0ff38f9cc08b6bc"),
  "name" : "Black-Software",
  "desc" : "卸载单个黑名单软件",
  "params" : [{
      "name" : "~softwareName~",
      "defaultValue" : "$null",
      "type" : "String"
    }, {
      "name" : "~processName~",
      "defaultValue" : "$null",
      "type" : "String"
    }, {
      "name" : "~isAuto~",
      "defaultValue" : "$false",
      "type" : "Boolean"
    }, {
      "name" : "~serviceName~",
      "defaultValue" : "$null",
      "type" : "String"
    }],
  "content" : "Function Black-Software{\r\n\tparam(\r\n\t\t[String] $hostUrl,\r\n\t\t[String] $softwareName,\r\n\t\t[String] $softwareVersion,\r\n\t\t[bool] $isAuto =$true,\r\n\t\t[String] $processName,\r\n\t\t[String] $serviceName\r\n\t);\r\n\t$business=\"[uninstall $softwareName]=>>\";\r\n\tIf([String]::isNullOrEmpty($softwareName)){Return \"softwareName can not empty\"}\r\n\t\r\n\t$retVal=Get-SoftwareInfoByNameVersion $softwareName $softwareVersion;\r\n\tIf($retVal -eq $null){Return Ret-Success \"${business}There is no software named $softwareName in the system\"}\r\n\tIf(!$isAuto){Return \"There is a prohibited software named $softwareName on the system\"}\r\n\r\n\tIf([String]::isNullOrEmpty($retVal.UninstallString)){Return \"Uninstall command does not exist, unable to uninstall\"}\r\n\r\n\tIf(![String]::isNullOrEmpty($serviceName)){(Set-Serviced $serviceName 'Disabled' 'Stopped')|Foreach{\"$business$_\"}}\r\n\r\n\tIf(![String]::isNullOrEmpty($processName)){(Set-Processd $processName $False $startFileDir $True)|Foreach{\"$business$_\"}}\r\n\r\n\t$UninstallString=$retVal.UninstallString.Trim().ToLower();\r\n\tIf($UninstallString.StartsWith('msiexec.exe')){\r\n\t\t$msicode=$UninstallString.substring($UninstallString.indexof('{'))\r\n\t\t$Res=OperatorSoftwareByMSI $msicode 'uninstall' $isAuto\r\n\t}Else{\r\n\t\t$Res=OperatorSoftwareBySWI $hostUrl $UninstallString $isAuto\r\n\t}\r\n\tIf(!(Is-Success $Res)){Return}\r\n\r\n\tIf((Get-SoftwareInfoByNameVersion $softwareName $softwareVersion) -ne $null){Return Ret-Processing \"Uninstallation has not been successful\"}\r\n\tReturn Ret-Success $business\r\n}",
  "callContent" : "",
  "subNames" : ["Ret-Success","Ret-Processing", "Is-Success", "Set-Serviced", "Set-Processd", "Get-SoftwareInfoByNameVersion", "OperatorSoftwareBySWI","OperatorSoftwareByMSI"],
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})

db.psScriptTemplate.remove({name:"ConvertToJson"});
db.psScriptTemplate.save({
  "_id" : ObjectId("5e6f385fa0ff38f9cc08b6bd"),
  "name" : "ConvertToJson",
  "desc" : "对象转接JSON",
  "params" : [],
  "content" : "Function ConvertToJson{\r\n\tparam($InputObject);\r\n\tif($InputObject -is [string]){\r\n\t\tif(![String]::isNullOrEmpty($InputObject)){$InputObject=$InputObject.replace('\\','/').trim()}\r\n\t\t\"`\"{0}`\"\" -f $InputObject\r\n\t}elseif($InputObject -is [bool]){\r\n\t\t$InputObject.ToString().ToLower();\r\n\t}elseif($InputObject -eq $null){\r\n\t\t\"null\"\r\n\t}elseif($InputObject -is [pscustomobject]){\r\n\t\t$result=\"{\";\r\n\t\t$properties=$InputObject|Get-Member -MemberType NoteProperty|ForEach-Object{\r\n\t\t\tif(![String]::isNullOrEmpty($_.Name)){\"`\"{0}`\":{1}\" -f  $_.Name,(ConvertToJson $InputObject.($_.Name))}\r\n\t\t};\r\n\t\t$result+=$properties -join \",\";\r\n\t\t$result+=\"}\";\r\n\t\t$result\r\n\t}elseif($InputObject -is [hashtable]){\r\n\t\t$result=\"{\";\r\n\t\t$properties=$InputObject.Keys|ForEach-Object{\r\n\t\t\tif(![String]::isNullOrEmpty($_)){\"`\"{0}`\":{1}\" -f  $_,(ConvertToJson $InputObject[$_])}\r\n\t\t};\r\n\t\t$result+=$properties -join \",\";\r\n\t\t$result+=\"}\";\r\n\t\t$result\r\n\t}elseif($InputObject -is [array]){\r\n\t\t$result=\"[\";\r\n\t\t$items=@();\r\n\t\tfor($i=0;$i -lt $InputObject.length;$i++){\r\n\t\t\tif(![String]::isNullOrEmpty($InputObject[$i])){$items+=ConvertToJson $InputObject[$i]}\r\n\t\t\t\r\n\t\t}\r\n\t\t$result+=$items -join \",\";\r\n\t\t$result+=\"]\";\r\n\t\t$result\r\n\t}else{\r\n\t\t\"`\"{0}`\"\" -f $InputObject.ToString().trim()\r\n\t}\r\n}",
  "callContent" : "",
  "subNames" : [],
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})

db.psScriptTemplate.remove({name:"Get-TerminalInfo"});
db.psScriptTemplate.save({
  "_id" : ObjectId("5e6f385fa0ff38f9cc08b6be"),
  "name" : "Get-TerminalInfo",
  "desc" : "获取终端信息",
  "isOpen" : true,
  "params" : [],
  "analyzingContent" : "package com.ruijie.authentication.session.program.domain.program;\r\ndialect  \"java\"\r\nimport com.ruijie.authentication.session.program.domain.program.PsScriptTemplateAnalyzingProcedureFact\r\nimport com.ruijie.authentication.authnode.domain.node.compliance.ComplianceDetectingResultState\r\nrule \"classify\"\r\nwhen\r\n    fact:PsScriptTemplateAnalyzingProcedureFact()\r\nthen\r\n    if(!fact.getScriptResponse().getResponse().endsWith(\"%%SMP:success\")){\r\n        fact.setResultState(ComplianceDetectingResultState.COMPLIANCE_FAIL);\r\n        fact.setResponse(fact.getScriptResponse().getResponse());\r\n    }\r\nend",
  "content" : "Function Get-TerminalInfo{\r\n\tFunction query($class){\r\n\t\t$arr=@();\r\n\t\t$obj=Invoke-Expression \"Get-WMIObject $class\"; \r\n\t\t$obj|Get-Member -MemberType Properties|Sort name|%{If(!$_.name.StartsWith('_')){$arr+=$_.name}}\r\n\t\t$obj|Select $arr\r\n\t}\r\n\t@{\t\r\n\t\twin32Bios=query Win32_BIOS;\r\n\t\twin32PhysicalMemoryList=query Win32_PhysicalMemory;\r\n\t\twin32Processor=query Win32_Processor;\r\n\t\twin32DiskDriveList=query Win32_DiskDrive;\r\n\t\twin32OperatingSystem=query Win32_OperatingSystem;\r\n\t\twin32LogicaldiskList=query Win32_Logicaldisk\r\n\t}\r\n}",
  "callContent" : "ConvertToJson(Get-TerminalInfo)",
  "subNames" : ["ConvertToJson"],
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

db.psScriptTemplate.remove({name:"Custom"});
db.psScriptTemplate.save({
  "_id" : ObjectId("5e717d5f91135576c890824f"),
  "name" : "Custom",
  "desc" : "自定义合规动作初始化脚本",
  "isOpen" : true,
  "params" : [],
  "analyzingContent" : "package com.ruijie.authentication.session.program.domain.program;\r\ndialect \"java\"\r\nimport com.ruijie.authentication.session.program.domain.program.PsScriptTemplateAnalyzingProcedureFact\r\nimport com.ruijie.authentication.authnode.domain.node.compliance.ComplianceDetectingResultState\r\nrule \"analyzingResult\"\r\nwhen\r\n\tfact:PsScriptTemplateAnalyzingProcedureFact()\r\nthen\r\n\tString response = fact.getScriptResponse().getResponse();\r\n\tfact.setResponse(response);\r\n\tfact.setOperateRecord(response);\r\n\tif(fact.getScriptResponse().isTimeout()==true){\r\n\t\tfact.setResultState(ComplianceDetectingResultState.TIME_OUT);\r\n\t\tfact.setResponse(\"script execution timeout\");\r\n\t}else{\r\n\t\tPsScriptTemplateAnalyzingProcedureFact.AnalyzingResult result = fact.parseObject(response);\r\n\t\tif(result.getMsg()!=null && result.getMsg().endsWith(\"%%SMP:processing\")){\r\n\t\t\tfact.setResultState(ComplianceDetectingResultState.COMPLYING);\r\n\t\t}else if(!result.isSuccess()){\r\n\t\t\tfact.setResultState(ComplianceDetectingResultState.COMPLIANCE_FAIL);\r\n\t\t}\r\n\t}\r\nend",
  "content" : "Function Execution-Script{\r\n\tparam(\r\n\t\t[String] $param1=$null,\r\n\t\t[Bool] $param2=$True\r\n\t)\r\n\t\r\n\t<#该脚本仅为示例,中间业务部分省去#>\r\n\t\r\n\t$Result=''|select isSuccess,msg,retObj;\r\n\t$Result.isSuccess='false';\r\n\t$Result.msg='获取xxx信息失败';\r\n\t$Result.retObj=$Null;\r\n\tReturn $Result;\r\n}",
  "callContent" : "Execution-Script -param1 $null -param2 $True|%{ConvertToJson $_}",
  "subNames" : ["ConvertToJson"],
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})

db.psScriptTemplate.remove({name:"WSUS-Patch"});
db.psScriptTemplate.save({
    "_id" : ObjectId("5e54ec999113553a104d2c20"),
    "name" : "WSUS-Patch",
    "desc" : "WSUS补丁脚本模板",
    "params" : [{
        "name" : "~hostUrl~",
        "defaultValue" : "$null"
    }, {
        "name" : "~updateServer~",
        "defaultValue" : "$null"
    }, {
        "name" : "~useWSUSServer~",
        "defaultValue" : "$null"
    }, {
        "name" : "~auOptions~",
        "defaultValue" : "$null"
    }, {
        "name" : "~scheduledInstallDay~",
        "defaultValue" : "$null"
    }, {
        "name" : "~scheduledInstallTime~",
        "defaultValue" : "$null"
    }],
    "analyzingContent" : "package com.ruijie.authentication.session.program.domain.program;\r\ndialect  \"java\"\r\nimport com.ruijie.authentication.session.program.domain.program.PsScriptTemplateAnalyzingProcedureFact\r\nimport com.ruijie.authentication.authnode.domain.node.compliance.ComplianceDetectingResultState\r\nrule \"classify\"\r\nwhen\r\n    fact:PsScriptTemplateAnalyzingProcedureFact()\r\nthen\r\n    if(fact.getScriptResponse().isTimeout()== true){\r\n        fact.setResultState(ComplianceDetectingResultState.COMPLIANCE_FAIL);\r\n        fact.setResponse(fact.getScriptResponse().getResponse());\r\n\t\tfact.setOperateRecord(\"execute script timeout!\");\r\n    }else if(!fact.getScriptResponse().getResponse().endsWith(\"%%SMP:success\")){\r\n\t\tfact.setResultState(ComplianceDetectingResultState.COMPLIANCE_FAIL);\r\n        fact.setResponse(fact.getScriptResponse().getResponse());\r\n\t\tfact.setOperateRecord(fact.getScriptResponse().getResponse());\r\n\t}else if(fact.getScriptResponse().getResponse().endsWith(\"%%SMP:success\")){\r\n     \t\tfact.setResultState(ComplianceDetectingResultState.COMPLIANCE_SUFFICE);\r\n            fact.setResponse(fact.getScriptResponse().getResponse());\r\n     \t\tfact.setOperateRecord(fact.getScriptResponse().getResponse());\r\n     }\r\nend",
    "content" : "function WSUS-Patch ($hostUrl,$updateServer,$useWSUSServer,$auOptions,$scheduledInstallDay,$scheduledInstallTime) {\r\n  $auOptionsToSet = $auOptions\r\n  if ($auOptions -eq \"InstallImmediately\") {\r\n    $auOptionsToSet = \"DownloadOnly\"\r\n  }\r\n  Set-ClientWSUSSetting -UpdateServer $updateServer -UseWSUSServer $useWSUSServer -AUOptions $auOptionsToSet -ScheduledInstallDay $scheduledInstallDay `\r\n    -ScheduledInstallTime $scheduledInstallTime ;\r\n\r\n  if ($auOptions -eq \"InstallImmediately\") {\r\n    if((Get-Process -name wuauclt -ErrorAction SilentlyContinue | measure).Count -le 1){\r\n        $SWIDir=Join-Path $env:SystemDrive '\\Program Files\\Ruijie Networks\\softwarePackage';\r\n\t    If(!(Test-Path $SWIDir)){\r\n\t\t    mkdir $SWIDir -Force|Out-Null;\r\n\t\t    If(!$?){Return Print-Exception \"mkdir $SWIDir -Force|Out-Null\"}\r\n\t    }\r\n\r\n\t    $SWIFileName='SWIService.exe';\r\n        if((Get-WmiObject -Class Win32_OperatingSystem).osarchitecture -match (\"64\")){\r\n            $SWIFileName='SWIService64.exe';\r\n        }\r\n\t    $SWIPath=Join-Path $SWIDir $SWIFileName;\r\n\t    $SWIServiceName='SWIserv';\r\n\t    $SWI=Get-Service -Name \"${SWIServiceName}*\"\r\n\t    If (!(Test-Path \"$SWIPath\")){\r\n\t\t    $remotePath=$hostUrl + $SWIFileName;\t\r\n\t\t    $Res=Download-File \"$remotePath\" \"$SWIPath\";\r\n\t    }\r\n\t\r\n\t    If($null -eq $SWI){\r\n\t\t    Try{\r\n\t\t\t    Set-Location $SWIDir; \r\n                if((Get-WmiObject -Class Win32_OperatingSystem).osarchitecture -match (\"64\")){\r\n\t\t\t        .\\SWIService64.exe -install -ErrorAction Stop\r\n                }else{\r\n                    .\\SWIService.exe -install -ErrorAction Stop\r\n                }\r\n\t\t    }Catch{\r\n\t\t\t    Return Print-Exception \".\\SWIService.exe -install -ErrorAction Stop\"\r\n\t\t    }\r\n\t    }else{\r\n\t\t    If($SWI.Status -eq 'Running'){\r\n\t\t\t    Stop-Service -Name $SWIServiceName -ErrorAction SilentlyContinue;\r\n\t\t\t    If(!$?){Return Print-Exception \"Stop-Service -Name $SWIServiceName\"}\r\n\t\t    }\r\n\t    }\r\n    \r\n\t    Try{\r\n            (Get-Service -Name $SWIServiceName).Start(\"{`\"exe`\":`\"wuauclt.exe`\",`\"arg`\":`\"/detectnow /updatenow`\"}\")\r\n\t    }Catch{\r\n\t\t    Return Print-Exception \"(Get-Service -Name $SWIServiceName).Start(`\"{`\"exe`\":`\"wuauclt.exe`\",`\"arg`\":`\"/detectnow /updatenow`\"}`\")\"\r\n\t    }\r\n    }\r\n  }\r\n  Return \"WSUS patch %%SMP:success\"\r\n}\r\n\r\nFunction Set-ClientWSUSSetting {\r\n    [cmdletbinding(\r\n        SupportsShouldProcess = $True\r\n    )]\r\n    Param (\r\n        [parameter(Position=0,ValueFromPipeLine = $True)]\r\n        [string[]]$Computername = $Env:Computername,\r\n        [parameter(Position=1)]\r\n        [string]$UpdateServer,\r\n        [parameter(Position=2)]\r\n        [string]$TargetGroup,\r\n        [parameter(Position=3)]\r\n        [switch]$DisableTargetGroup,         \r\n        [parameter(Position=4)]\r\n        [ValidateSet('Notify','DownloadOnly','DownloadAndInstall','AllowUserConfig')]\r\n        [string]$AUOptions,\r\n        [parameter(Position=5)]\r\n        [ValidateRange(1,22)]\r\n        [Int32]$DetectionFrequency,\r\n        [parameter(Position=6)]\r\n        [switch]$DisableDetectionFrequency,        \r\n        [parameter(Position=7)]\r\n        [ValidateRange(1,1440)]\r\n        [Int32]$RebootLaunchTimeout,\r\n        [parameter(Position=8)]\r\n        [switch]$DisableRebootLaunchTimeout,        \r\n        [parameter(Position=9)]\r\n        [ValidateRange(1,30)]  \r\n        [Int32]$RebootWarningTimeout,\r\n        [parameter(Position=10)]\r\n        [switch]$DisableRebootWarningTimeout,        \r\n        [parameter(Position=11)]\r\n        [ValidateRange(1,60)]\r\n        [Int32]$RescheduleWaitTime,\r\n        [parameter(Position=12)]\r\n        [switch]$DisableRescheduleWaitTime,        \r\n        [parameter(Position=13)]\r\n        [ValidateSet('EveryDay','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday')]\r\n        [ValidateCount(1,1)]\r\n        [string[]]$ScheduledInstallDay,\r\n        [parameter(Position=14)]\r\n        [ValidateRange(0,23)]\r\n        [Int32]$ScheduledInstallTime,\r\n        [parameter(Position=15)]\r\n        [ValidateSet('Enable','Disable')]\r\n        [string]$ElevateNonAdmins,    \r\n        [parameter(Position=16)]\r\n        [ValidateSet('Enable','Disable')]\r\n        [string]$AllowAutomaticUpdates,  \r\n        [parameter(Position=17)]\r\n        [ValidateSet('Enable','Disable')]\r\n        [string]$UseWSUSServer,\r\n        [parameter(Position=18)]\r\n        [ValidateSet('Enable','Disable')]\r\n        [string]$AutoInstallMinorUpdates,\r\n        [parameter(Position=19)]\r\n        [ValidateSet('Enable','Disable')]\r\n        [string]$AutoRebootWithLoggedOnUsers                                              \r\n    )\r\n    Begin {\r\n    }\r\n    Process {\r\n        $PSBoundParameters.GetEnumerator() | ForEach {\r\n            Write-Verbose (\"{0}\" -f $_)\r\n        }\r\n        ForEach ($Computer in $Computername) {\r\n            If (Test-Connection -ComputerName $Computer -Count 1 -Quiet) {\r\n                $WSUSEnvhash = @{}\r\n                $WSUSConfigHash = @{}\r\n                $ServerReg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey(\"LocalMachine\",$Computer) \r\n                #Check to see if WSUS registry keys exist\r\n                $temp = $ServerReg.OpenSubKey('Software\\Policies\\Microsoft\\Windows',$True)\r\n                If (-NOT ($temp.GetSubKeyNames() -contains 'WindowsUpdate')) {\r\n                    #Build the required registry keys\r\n                    $temp.CreateSubKey('WindowsUpdate\\AU') | Out-Null\r\n                }\r\n                #Set WSUS Client Environment Options\r\n                $WSUSEnv = $ServerReg.OpenSubKey('Software\\Policies\\Microsoft\\Windows\\WindowsUpdate',$True)\r\n                If ($PSBoundParameters['ElevateNonAdmins']) {\r\n                    If ($ElevateNonAdmins -eq 'Enable') {\r\n                        If ($pscmdlet.ShouldProcess(\"Elevate Non-Admins\",\"Enable\")) {\r\n                            $WsusEnv.SetValue('ElevateNonAdmins',1,[Microsoft.Win32.RegistryValueKind]::DWord)\r\n                        }\r\n                    } ElseIf ($ElevateNonAdmins -eq 'Disable') {\r\n                        If ($pscmdlet.ShouldProcess(\"Elevate Non-Admins\",\"Disable\")) {\r\n                            $WsusEnv.SetValue('ElevateNonAdmins',0,[Microsoft.Win32.RegistryValueKind]::DWord)\r\n                        }\r\n                    }\r\n                }\r\n                If ($PSBoundParameters['UpdateServer']) {\r\n                    If ($pscmdlet.ShouldProcess(\"WUServer\",\"Set Value\")) {\r\n                        $WsusEnv.SetValue('WUServer',$UpdateServer,[Microsoft.Win32.RegistryValueKind]::String)\r\n                    }\r\n                    If ($pscmdlet.ShouldProcess(\"WUStatusServer\",\"Set Value\")) {\r\n                        $WsusEnv.SetValue('WUStatusServer',$UpdateServer,[Microsoft.Win32.RegistryValueKind]::String)\r\n                    }\r\n                }\r\n                If ($PSBoundParameters['TargetGroup']) {\r\n                    If ($pscmdlet.ShouldProcess(\"TargetGroup\",\"Enable\")) {\r\n                        $WsusEnv.SetValue('TargetGroupEnabled',1,[Microsoft.Win32.RegistryValueKind]::Dword)\r\n                    }\r\n                    If ($pscmdlet.ShouldProcess(\"TargetGroup\",\"Set Value\")) {\r\n                        $WsusEnv.SetValue('TargetGroup',$TargetGroup,[Microsoft.Win32.RegistryValueKind]::String)\r\n                    }\r\n                }    \r\n                If ($PSBoundParameters['DisableTargetGroup']) {\r\n                    If ($pscmdlet.ShouldProcess(\"TargetGroup\",\"Disable\")) {\r\n                        $WsusEnv.SetValue('TargetGroupEnabled',0,[Microsoft.Win32.RegistryValueKind]::Dword)\r\n                    }\r\n                }      \r\n                                       \r\n                #Set WSUS Client Configuration Options\r\n                $WSUSConfig = $ServerReg.OpenSubKey('Software\\Policies\\Microsoft\\Windows\\WindowsUpdate\\AU',$True)\r\n                If ($PSBoundParameters['AUOptions']) {\r\n                    If ($pscmdlet.ShouldProcess(\"AUOptions\",\"Set Value\")) {\r\n                        If ($AUOptions -eq 'Notify') {\r\n                            $WsusConfig.SetValue('AUOptions',2,[Microsoft.Win32.RegistryValueKind]::DWord)\r\n                        } ElseIf ($AUOptions -eq 'DownloadOnly') {\r\n                            $WsusConfig.SetValue('AUOptions',3,[Microsoft.Win32.RegistryValueKind]::DWord)\r\n                        } ElseIf ($AUOptions -eq 'DownloadAndInstall') {\r\n                            $WsusConfig.SetValue('AUOptions',4,[Microsoft.Win32.RegistryValueKind]::DWord)\r\n                        } ElseIf ($AUOptions -eq 'AllowUserConfig') {\r\n                            $WsusConfig.SetValue('AUOptions',5,[Microsoft.Win32.RegistryValueKind]::DWord)\r\n                        }\r\n                    }\r\n                } \r\n                If ($PSBoundParameters['DetectionFrequency']) {\r\n                    If ($pscmdlet.ShouldProcess(\"DetectionFrequency\",\"Enable\")) {\r\n                        $WsusConfig.SetValue('DetectionFrequencyEnabled',1,[Microsoft.Win32.RegistryValueKind]::DWord)\r\n                    }\r\n                    If ($pscmdlet.ShouldProcess(\"DetectionFrequency\",\"Set Value\")) {\r\n                        $WsusConfig.SetValue('DetectionFrequency',$DetectionFrequency,[Microsoft.Win32.RegistryValueKind]::DWord)\r\n                    }\r\n                }\r\n                If ($PSBoundParameters['DisableDetectionFrequency']) {\r\n                    If ($pscmdlet.ShouldProcess(\"DetectionFrequency\",\"Disable\")) {\r\n                        $WsusConfig.SetValue('DetectionFrequencyEnabled',0,[Microsoft.Win32.RegistryValueKind]::DWord)\r\n                    }\r\n                } \r\n                If ($PSBoundParameters['RebootWarningTimeout']) {\r\n                    If ($pscmdlet.ShouldProcess(\"RebootWarningTimeout\",\"Enable\")) {\r\n                        $WsusConfig.SetValue('RebootWarningTimeoutEnabled',1,[Microsoft.Win32.RegistryValueKind]::DWord)\r\n                    }\r\n                    If ($pscmdlet.ShouldProcess(\"RebootWarningTimeout\",\"Set Value\")) {\r\n                        $WsusConfig.SetValue('RebootWarningTimeout',$RebootWarningTimeout,[Microsoft.Win32.RegistryValueKind]::DWord)\r\n                    }\r\n                }\r\n                If ($PSBoundParameters['DisableRebootWarningTimeout']) {\r\n                    If ($pscmdlet.ShouldProcess(\"RebootWarningTimeout\",\"Disable\")) {\r\n                        $WsusConfig.SetValue('RebootWarningTimeoutEnabled',0,[Microsoft.Win32.RegistryValueKind]::DWord)\r\n                    }\r\n                }   \r\n                If ($PSBoundParameters['RebootLaunchTimeout']) {\r\n                    If ($pscmdlet.ShouldProcess(\"RebootLaunchTimeout\",\"Enable\")) {\r\n                        $WsusConfig.SetValue('RebootLaunchTimeoutEnabled',1,[Microsoft.Win32.RegistryValueKind]::DWord)\r\n                    }\r\n                    If ($pscmdlet.ShouldProcess(\"RebootLaunchTimeout\",\"Set Value\")) {\r\n                        $WsusConfig.SetValue('RebootLaunchTimeout',$RebootLaunchTimeout,[Microsoft.Win32.RegistryValueKind]::DWord)\r\n                    }\r\n                }\r\n                If ($PSBoundParameters['DisableRebootLaunchTimeout']) {\r\n                    If ($pscmdlet.ShouldProcess(\"RebootWarningTimeout\",\"Disable\")) {\r\n                        $WsusConfig.SetValue('RebootLaunchTimeoutEnabled',0,[Microsoft.Win32.RegistryValueKind]::DWord)\r\n                    }\r\n                } \r\n                If ($PSBoundParameters['ScheduledInstallDay']) {\r\n                    If ($pscmdlet.ShouldProcess(\"ScheduledInstallDay\",\"Set Value\")) {\r\n                        If ($ScheduledInstallDay -eq 'EveryDay') {\r\n                            $WsusConfig.SetValue('ScheduledInstallDay',0,[Microsoft.Win32.RegistryValueKind]::DWord)\r\n                        } ElseIf ($ScheduledInstallDay -eq 'Monday') {\r\n                            $WsusConfig.SetValue('ScheduledInstallDay',1,[Microsoft.Win32.RegistryValueKind]::DWord)\r\n                        } ElseIf ($ScheduledInstallDay -eq 'Tuesday') {\r\n                            $WsusConfig.SetValue('ScheduledInstallDay',2,[Microsoft.Win32.RegistryValueKind]::DWord)\r\n                        } ElseIf ($ScheduledInstallDay -eq 'Wednesday') {\r\n                            $WsusConfig.SetValue('ScheduledInstallDay',3,[Microsoft.Win32.RegistryValueKind]::DWord)\r\n                        } ElseIf ($ScheduledInstallDay -eq 'Thursday') {\r\n                            $WsusConfig.SetValue('ScheduledInstallDay',4,[Microsoft.Win32.RegistryValueKind]::DWord)\r\n                        } ElseIf ($ScheduledInstallDay -eq 'Friday') {\r\n                            $WsusConfig.SetValue('ScheduledInstallDay',5,[Microsoft.Win32.RegistryValueKind]::DWord)\r\n                        } ElseIf ($ScheduledInstallDay -eq 'Saturday') {\r\n                            $WsusConfig.SetValue('ScheduledInstallDay',6,[Microsoft.Win32.RegistryValueKind]::DWord)\r\n                        } ElseIf ($ScheduledInstallDay -eq 'Sunday') {\r\n                            $WsusConfig.SetValue('ScheduledInstallDay',7,[Microsoft.Win32.RegistryValueKind]::DWord)\r\n                        }\r\n                    }\r\n                }   \r\n                If ($PSBoundParameters['RescheduleWaitTime']) {\r\n                    If ($pscmdlet.ShouldProcess(\"RescheduleWaitTime\",\"Enable\")) {\r\n                        $WsusConfig.SetValue('RescheduleWaitTimeEnabled',1,[Microsoft.Win32.RegistryValueKind]::DWord)\r\n                    }\r\n                    If ($pscmdlet.ShouldProcess(\"RescheduleWaitTime\",\"Set Value\")) {\r\n                        $WsusConfig.SetValue('RescheduleWaitTime',$RescheduleWaitTime,[Microsoft.Win32.RegistryValueKind]::DWord)\r\n                    }\r\n                }\r\n                If ($PSBoundParameters['DisableRescheduleWaitTime']) {\r\n                    If ($pscmdlet.ShouldProcess(\"RescheduleWaitTime\",\"Disable\")) {\r\n                        $WsusConfig.SetValue('RescheduleWaitTimeEnabled',0,[Microsoft.Win32.RegistryValueKind]::DWord)\r\n                    }\r\n                  } \r\n                If ($PSBoundParameters['ScheduledInstallTime']) {\r\n                    If ($pscmdlet.ShouldProcess(\"ScheduledInstallTime\",\"Set Value\")) {\r\n                        $WsusConfig.SetValue('ScheduledInstallTime',$ScheduledInstallTime,[Microsoft.Win32.RegistryValueKind]::DWord)\r\n                    }\r\n                }   \r\n                If ($PSBoundParameters['AllowAutomaticUpdates']) {\r\n                    If ($AllowAutomaticUpdates -eq 'Enable') {\r\n                        If ($pscmdlet.ShouldProcess(\"AllowAutomaticUpdates\",\"Enable\")) {\r\n                            $WsusConfig.SetValue('NoAutoUpdate',1,[Microsoft.Win32.RegistryValueKind]::DWord)\r\n                        }\r\n                    } ElseIf ($AllowAutomaticUpdates -eq 'Disable') {\r\n                        If ($pscmdlet.ShouldProcess(\"AllowAutomaticUpdates\",\"Disable\")) {\r\n                            $WsusConfig.SetValue('NoAutoUpdate',0,[Microsoft.Win32.RegistryValueKind]::DWord)\r\n                        }\r\n                    }\r\n                } \r\n                If ($PSBoundParameters['UseWSUSServer']) {\r\n                    If ($UseWSUSServer -eq 'Enable') {\r\n                        If ($pscmdlet.ShouldProcess(\"UseWSUSServer\",\"Enable\")) {\r\n                            $WsusConfig.SetValue('UseWUServer',1,[Microsoft.Win32.RegistryValueKind]::DWord)\r\n                        }\r\n                    } ElseIf ($UseWSUSServer -eq 'Disable') {\r\n                        If ($pscmdlet.ShouldProcess(\"UseWSUSServer\",\"Disable\")) {\r\n                            $WsusConfig.SetValue('UseWUServer',0,[Microsoft.Win32.RegistryValueKind]::DWord)\r\n                            Remove-ItemProperty hklm:\\Software\\Policies\\Microsoft\\Windows\\WindowsUpdate WUServer -Force -ErrorAction SilentlyContinue\r\n                            Remove-ItemProperty hklm:\\Software\\Policies\\Microsoft\\Windows\\WindowsUpdate WUStatusServer -Force -ErrorAction SilentlyContinue\r\n                        }\r\n                    }\r\n                }\r\n                If ($PSBoundParameters['AutoInstallMinorUpdates']) {\r\n                    If ($AutoInstallMinorUpdates -eq 'Enable') {\r\n                        If ($pscmdlet.ShouldProcess(\"AutoInstallMinorUpdates\",\"Enable\")) {\r\n                            $WsusConfig.SetValue('AutoInstallMinorUpdates',1,[Microsoft.Win32.RegistryValueKind]::DWord)\r\n                        }\r\n                    } ElseIf ($AutoInstallMinorUpdates -eq 'Disable') {\r\n                        If ($pscmdlet.ShouldProcess(\"AutoInstallMinorUpdates\",\"Disable\")) {\r\n                            $WsusConfig.SetValue('AutoInstallMinorUpdates',0,[Microsoft.Win32.RegistryValueKind]::DWord)\r\n                        }\r\n                    }\r\n                }  \r\n                If ($PSBoundParameters['AutoRebootWithLoggedOnUsers']) {\r\n                    If ($AutoRebootWithLoggedOnUsers -eq 'Enable') {\r\n                        If ($pscmdlet.ShouldProcess(\"AutoRebootWithLoggedOnUsers\",\"Enable\")) {\r\n                            $WsusConfig.SetValue('NoAutoRebootWithLoggedOnUsers',1,[Microsoft.Win32.RegistryValueKind]::DWord)\r\n                        }\r\n                    } ElseIf ($AutoRebootWithLoggedOnUsers -eq 'Disable') {\r\n                        If ($pscmdlet.ShouldProcess(\"AutoRebootWithLoggedOnUsers\",\"Disable\")) {\r\n                            $WsusConfig.SetValue('NoAutoRebootWithLoggedOnUsers',0,[Microsoft.Win32.RegistryValueKind]::DWord)\r\n                        }\r\n                    }\r\n                }                                                                                                                                          \r\n            } Else {\r\n                Write-Warning (\"{0}: Unable to connect!\" -f $Computer)\r\n            }\r\n        }\r\n    }\r\n}",
    "callContent" : "WSUS-Patch ~hostUrl~ ~updateServer~ ~useWSUSServer~ ~auOptions~ ~scheduledInstallDay~ ~scheduledInstallTime~",
    "subNames" : ["Print-Exception", "Is-Success", "Download-File", "Ret-Success"],
    "_version_" : "0",
    "createTime" :new Date(),
    "lastModifiedTime" :new Date(),
    "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})

db.psScriptTemplate.remove({name:"WSUS-Check-Install"});
db.psScriptTemplate.save({
    "_id" : ObjectId("5e4e41b5542c78176cfbf08a"),
    "name" : "WSUS-Check-Install",
    "desc" : "WSUS补丁安装结果校验模板",
    "params" : [{
        "name" : "~updateClassification~",
        "defaultValue" : "$null"
    }, {
        "name" : "~failedMaxCount~",
        "defaultValue" : "$null"
    }],
    "analyzingContent" : "package com.ruijie.authentication.session.program.domain.program;\r\ndialect  \"java\"\r\nimport com.ruijie.authentication.session.program.domain.program.PsScriptTemplateAnalyzingProcedureFact\r\nimport com.ruijie.authentication.authnode.domain.node.compliance.ComplianceDetectingResultState\r\nrule \"classify\"\r\nwhen\r\n    fact:PsScriptTemplateAnalyzingProcedureFact()\r\nthen\r\n    if(fact.getScriptResponse().isTimeout()== true){\r\n        fact.setResultState(ComplianceDetectingResultState.COMPLIANCE_FAIL);\r\n        fact.setResponse(fact.getScriptResponse().getResponse());\r\n\t\tfact.setOperateRecord(\"execute script timeout!\");\r\n    }else if(!fact.getScriptResponse().getResponse().endsWith(\"%%SMP:success\")){\r\n\t\tfact.setResultState(ComplianceDetectingResultState.COMPLIANCE_FAIL);\r\n        fact.setResponse(fact.getScriptResponse().getResponse());\r\n\t\tfact.setOperateRecord(fact.getScriptResponse().getResponse());\r\n\t}else if(fact.getScriptResponse().getResponse().endsWith(\"%%SMP:success\")){\r\n     \t\tfact.setResultState(ComplianceDetectingResultState.COMPLIANCE_SUFFICE);\r\n            fact.setResponse(fact.getScriptResponse().getResponse());\r\n     \t\tfact.setOperateRecord(fact.getScriptResponse().getResponse());\r\n     }\r\nend",
    "content" : "function WSUS-Check-Install ($hostName, $updateClassification,$failedMaxCount){\r\n    [void][reflection.assembly]::LoadWithPartialName(\"Microsoft.UpdateServices.Administration\"); \r\n    $computerName = $hostName; \r\n    try { \r\n        $wsus = [Microsoft.UpdateServices.Administration.AdminProxy]::getUpdateServer();\r\n        $computer = $wsus.GetComputerTargetByName($computerName); \r\n        $updateScope = New-Object Microsoft.UpdateServices.Administration.UpdateScope; \r\n        $classfications = $wsus.GetUpdateClassifications() | Where-Object { $_.Title -in @($updateClassification) }; \r\n        $updateScope.Classifications.Clear(); $updateScope.Classifications.AddRange($classfications); \r\n        $updateScope.IncludedInstallationStates = [Microsoft.UpdateServices.Administration.UpdateInstallationStates]::NotInstalled -bor \r\n            [Microsoft.UpdateServices.Administration.UpdateInstallationStates]::Failed; \r\n        $summary = $computer.GetUpdateInstallationSummary($updateScope); \r\n        $count = $summary.NotInstalledCount + $summary.FailedCount; \r\n        if ($count -le $failedMaxCount) { \r\n            Write-Host \"WSUS-Check-Install %%SMP:success\"; \r\n        } else {\r\n            Write-Host \"WSUS-Check-Install count $count %%SMP:fail\"; \r\n        }\r\n    } catch {\r\n        Write-Host \"WSUS-Check-Install exception: $Error[0] %%SMP:fail\"; \r\n    }\r\n}",
    "callContent" : "WSUS-Check-Install ~hostName~ ~updateClassification~ ~failedMaxCount~",
    "subNames" : ["Print-Exception"],
    "_version_" : "0",
    "createTime" :new Date(),
    "lastModifiedTime" :new Date(),
    "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})

db.psScriptTemplate.remove({name:"Test-FileLocked"});
db.psScriptTemplate.save({
  "_id" : ObjectId("5e85bb94911355b228adc83a"),
  "name" : "Test-FileLocked",
  "desc" : "检查文件是否锁住",
  "content" : "Function Test-FileLocked([string]$FilePath) {\r\n    try {[IO.File]::OpenWrite($FilePath).close();$false}catch{$true}\r\n}",
  "callContent" : "",
  "subNames" : [],
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})

db.psScriptTemplate.remove({name:"Handle-Error"});
db.psScriptTemplate.save({
  "_id" : ObjectId("5eba29de91135523981dec1b"),
  "name" : "Handle-Error",
  "desc" : "处理错误",
  "content" : "Function Handle-Error{\r\n\tIf($error){\r\n\t\t$t=$error.count-1;\r\n\t\t$rea=@();\r\n\t\tForeach ($i in 0..$t){\r\n\t\t\t$rea+=$error[$i].toString()\r\n\t\t}\r\n\t\t$rea\r\n\t}Else{\r\n\t\t\"Execution successful %%SMP:success\"\r\n\t}\r\n}",
  "callContent" : "",
  "subNames" : [],
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})

db.psScriptTemplate.remove({name:"Unified-Return"});
db.psScriptTemplate.save({
  "_id" : ObjectId("5eb9fd7f91135523981dec12"),
  "name" : "Unified-Return",
  "desc" : "统一返回结果",
  "content" : "Function Unified-Return([Object[]]$msgs,[Parameter(Mandatory = $true)][String]$business){\r\n\tIf($msgs -eq $Null -Or $msgs.count -eq 0){\r\n\t\t$isSuccess='false';\r\n\t\t$msg='No message returned';\r\n\t}Else{\r\n\t\tIf(($msgs[-1]).EndsWith('%%SMP:success')){\r\n\t\t\t$isSuccess='true';\r\n\t\t}Else{\r\n\t\t\t$isSuccess='false';\r\n\t\t}\r\n\t\t$msg=($msgs -Join ';\t').replace('\\','/')\r\n\t}\r\n\tReturn \"{`\"isSuccess`\":`\"$isSuccess`\",`\"msg`\":`\"$msg`\",`\"business`\":`\"$business`\"}\";\r\n}",
  "callContent" : "",
  "subNames" : [],
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})

db.psScriptTemplate.remove({name:"Check-JoinAD"});
db.psScriptTemplate.save({
  "_id" : ObjectId("5eb921cc9113552f305afb7e"),
  "name" : "Check-JoinAD",
  "desc" : "检查是否加域",
  "content" : "Function Check-JoinAD(){\r\n\t$IsJoinAD=(Get-WmiObject Win32_ComputerSystem).PartOfDomain\r\n\tIf($IsJoinAD){\r\n\t\t\"{`\"isSuccess`\":`\"true`\"}\"\r\n\t}else{\r\n\t\t\"{`\"isSuccess`\":`\"false`\"}\"\r\n\t}\r\n}",
  "callContent" : "Check-JoinAD",
  "subNames" : [],
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})

db.psScriptTemplate.remove({name:"Set-ServicedF"});
db.psScriptTemplate.save({
  "_id" : ObjectId("5eb910f39113552f305afb77"),
  "name" : "Set-ServicedF",
  "desc" : "服务操作--接口",
  "content" : "Filter Set-ServicedF{\r\n\tReturn Set-Serviced $_.serviceName $_.startType $_.status\r\n}",
  "callContent" : "",
  "subNames" : ["Set-Serviced"],
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})

db.psScriptTemplate.remove({name:"Set-ServicedArr"});
db.psScriptTemplate.save({
  "_id" : ObjectId("5eb911ad9113552f305afb78"),
  "name" : "Set-ServicedArr",
  "desc" : "批量操作服务",
  "content" : "Function Set-ServicedArr([Object[]]$operator,[String]$action){\r\n\t$ErrorActionPreference='SilentlyContinue';\r\n\t$msg=@();$err=0;\r\n\tIf($action -eq 'enable'){\r\n\t\t$startType='Automatic';\r\n\t\t$status='Running'\r\n\t}Else{\r\n\t\t$startType='Disabled';\r\n\t\t$status='Stopped'\r\n\t}\r\n\t\r\n\tConvertFrom-Csv $operator|%{Set-Serviced $_.serviceName $startType $status}|%{If(!$_.EndsWith('%%SMP:success')){$err++}$msg+=$_;}\r\n\t\r\n\tIf($err -eq 0){$isSuccess='true'}Else{$isSuccess='false'}\r\n\t$t=($msg -join ' ; ').replace('\\','/');\r\n\t\"{`\"isSuccess`\":`\"$isSuccess`\",`\"msg`\":`\"$t`\"}\"\r\n}",
  "callContent" : "Set-ServicedArr @('serviceName','WinRM','ftpsvc') $action",
  "subNames" : ["Set-ServicedF"],
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})
db.psScriptTemplate.remove({name:"Disable-ServicedArr"});
db.psScriptTemplate.save({
  "_id" : ObjectId("5eba470b91135523981dec23"),
  "name" : "Disable-ServicedArr",
  "desc" : "批量禁用服务",
  "content" : "Function Disable-ServicedArr([Object[]]$operator){\r\n\tSet-ServicedArr $operator 'disable'\r\n}",
  "callContent" : "<#\r\n!!以上代码均为固定模式,非专业人士不要修改!!\r\n!!以下代码为调度部分;调度部分用法如下\r\n不可修改部分:\r\n\tDisable-ServicedArr\"\t=>调度方法\r\n\t\"serviceName\" \t\t=>服务名导航字段\r\n可修改部分: \r\n\t服务名,用户可根据实际业务需要进行新增或删除\r\n功能:\r\n\t禁用指定服务操作\r\n格式: Disable-ServicedArr @( \"serviceName\",\"服务名1\",...,\"服务名n\" )\r\n#>\r\nDisable-ServicedArr @('serviceName','WinRM','ftpsvc')",
  "subNames" : ["Set-ServicedArr"],
  "_version_" : "0",
  "createTime" : ISODate("2020-04-10T03:38:41.846Z"),
  "lastModifiedTime" : ISODate("2020-04-10T03:38:41.846Z"),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})

db.psScriptTemplate.remove({name:"Enable-ServicedArr"});
db.psScriptTemplate.save({
  "_id" : ObjectId("5eba492e91135523981dec25"),
  "name" : "Enable-ServicedArr",
  "desc" : "批量启用服务",
  "content" : "Function Enable-ServicedArr([Object[]]$operator){\r\n\tSet-ServicedArr $operator 'enable'\r\n}",
  "callContent" : "<#\r\n!!以上代码均为固定模式,非专业人士不要修改!!\r\n!!以下代码为调度部分;调度部分用法如下\r\n不可修改部分:\r\n\t\"Enable-ServicedArr\"\t=>调度方法\r\n\t\"serviceName\" \t\t=>服务名导航字段\r\n可修改部分: \r\n\t服务名,用户可根据实际业务需要进行新增或删除\r\n功能:\r\n\t启用指定服务操作\r\n格式: Enable-ServicedArr @( \"serviceName\",\"服务名1\",...,\"服务名n\" )\r\n#>\r\nEnable-ServicedArr @('serviceName','WinRM','ftpsvc')",
  "subNames" : ["Set-ServicedArr"],
  "_version_" : "0",
  "createTime" : ISODate("2020-04-10T03:38:41.846Z"),
  "lastModifiedTime" : ISODate("2020-04-10T03:38:41.846Z"),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})

db.psScriptTemplate.remove({name:"Set-ProcessdF"});
db.psScriptTemplate.save({
  "_id" : ObjectId("5eb91c7f9113552f305afb7a"),
  "name" : "Set-ProcessdF",
  "desc" : "进程操作-接口",
  "content" : "Filter Set-ProcessdF{\r\n\tSet-Processd -processName $_.processName -isRun ('true' -eq $_.isRun) -startFile $_.startFile -isClear ('true' -eq $_.isClear)\r\n}",
  "callContent" : "",
  "subNames" : ["Set-Processd"],
  "_version_" : "0",
  "createTime" : ISODate("2020-04-10T03:38:41.886Z"),
  "lastModifiedTime" : ISODate("2020-04-10T03:38:41.886Z"),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})

db.psScriptTemplate.remove({name:"Kill-ProcessdArr"});
db.psScriptTemplate.save({
  "_id" : ObjectId("5eb91cf39113552f305afb7c"),
  "name" : "Kill-ProcessdArr",
  "desc" : "批量杀操作进程",
  "content" : "Function Kill-ProcessdArr([Object[]]$operator){\r\n\t$ErrorActionPreference='SilentlyContinue';\r\n\t$msg=@();\r\n\tConvertFrom-Csv $operator|Set-ProcessdF|%{$msg+=$_}\r\n\tIf($error.count -eq 0){$isSuccess='true'}Else{$isSuccess='false';#$msg+=$error\r\n\t}\r\n\t$t=($msg -join ' ; ').replace('\\','/');\r\n\t\"{`\"isSuccess`\":`\"$isSuccess`\",`\"msg`\":`\"$t`\"}\"\r\n}",
  "callContent" : "<#\r\n!!以上代码均为固定模式,非专业人士不要修改!!\r\n!!以下代码为调度部分;调度部分用法如下\r\n不可修改部分:\r\n\t\"Set-ProcessdArr\"\t=>调度方法\r\n\t\"processName\" \t\t=>进程名 导航字段\r\n可修改部分: \r\n\t进程名,用户可根据实际业务需要进行新增或删除\r\n功能:\r\n\t杀死指定进程操作\r\n格式: Set-ProcessdArr @( \"processName\",\"进程名1\",...,\"进程名n\" )\r\n#>\r\nKill-ProcessdArr @(\"processName\",\"notepad++\",\"WeChat\")",
  "subNames" : ["Set-ProcessdF"],
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})

db.psScriptTemplate.remove({name:"Uninstall-SoftwareArr"});
db.psScriptTemplate.save({
  "_id" : ObjectId("5ebe5a6991135530201007d2"),
  "name" : "Uninstall-SoftwareArr",
  "desc" : "批量卸载软件",
  "params" : [{
      "name" : "~softwareList~",
      "defaultValue" : "$null",
      "type" : "Array"
    }],
  "content" : "Function Uninstall-SoftwareArr($hostUrl,$softwares){\r\n\t$suc=0;\r\n\t$res=1|Select isSuccess,msg,business;\r\n\tConvertFrom-Csv $softwares|%{\r\n\t\t$ret=Black-Software $hostUrl (UnicodeToChinese $_.softwareName);$res.msg+=\"\t$($_) :$ret\";\r\n\t\tIf(Is-Success $ret){$suc+=1}\r\n\t}\r\n\t$res.isSuccess=$suc -eq ($softwares.length-1);\r\n\t$res.business='Uninstall-SoftwareArr';\r\n\tReturn ConvertToJson $res\r\n}",
  "callContent" : "<#\r\n!!以上代码均为固定模式,非专业人士不要修改!!\r\n!!以下代码为调度部分;调度部分用法如下\r\n不可修改部分:\r\n\t\"Uninstall-SoftwareArr\"\t=>调度方法\r\n\t\"softwareName\" \t\t=>软件名导航字段\r\n可修改部分: \r\n\t软件名,用户可根据实际业务需要进行新增或删除,若软件名为空中文,请先将其换成Unicode编码,以规避不同系统环境乱码并导致无法正常执行\r\n\t$hostUrl 应修改为软件安装包的下载地址\r\n功能:\r\n\t卸载wifi代理工具\r\n格式: Uninstall-SoftwareArr $hostUrl @( \"softwareName\" ,\"软件名1\",...,\"软件名n\" )\r\n#>\r\nUninstall-SoftwareArr \"http://172.17.8.56:9888//nodeManager/file/download/\" @(\"softwareName\",\"360免费WiFi\",\"猎豹免费WIFI\")",
  "analyzingContent" : "package com.ruijie.authentication.session.program.domain.program;\r\ndialect  \"java\"\r\nimport com.ruijie.authentication.session.program.domain.program.PsScriptTemplateAnalyzingProcedureFact\r\nimport com.ruijie.authentication.authnode.domain.node.compliance.ComplianceDetectingResultState\r\nimport com.ruijie.common.utils.CsvUtil\r\nimport java.util.List\r\nrule \"classify\"\r\nwhen\r\n    fact:PsScriptTemplateAnalyzingProcedureFact()\r\nthen\r\n    String response = fact.getScriptResponse().getResponse();\r\n    fact.setResultState(ComplianceDetectingResultState.COMPLIANCE_FAIL);\r\n    List<PsBatchResult> csvData = CsvUtil.getCsvData(response, PsBatchResult.class);\r\n    if(!csvData.isEmpty()){\r\n        PsBatchResult psRetResult = csvData.get(0);\r\n        if(psRetResult.getSuccess()==psRetResult.getSum()){\r\n            fact.setResultState(ComplianceDetectingResultState.COMPLIANCE_SUFFICE);\r\n        }\r\n    }\r\n    fact.setResponse(response);\r\nend",
  "subNames" : ["Black-Software", "UnicodeToChinese","ConvertToJson"],
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})

db.psScriptTemplate.remove({name:"Get-RemovableDisk"});
db.psScriptTemplate.save({
  "_id" : ObjectId("5ed8cee29113552f6cdce7ca"),
  "name" : "Get-RemovableDisk",
  "desc" : "获取可移动磁盘的盘符",
  "params" : [],
  "content" : "Function Get-RemovableDisk{\r\n\tIf($PSVersionTable.PSVersion.Major -ge 4){\r\n\t\tReturn [Object[]](Get-Disk|? BusType -eq USB|Get-Partition|Get-Volume|%{If($_.DriveLetter){$_.DriveLetter.substring(0,1)}})\r\n\t}\r\n\t$Array=@()\r\n\t$USBDrives=gwmi win32_DiskDrive|?{ $_.InterfaceType -eq 'USB' }\r\n\tIf($USBDrives -eq $null){Return $Array}\r\n\t$DriveToPartitionMappings=gwmi Win32_DiskDriveToDiskPartition|Select Antecedent,Dependent\r\n\t$LogicalDiskMappings=gwmi Win32_LogicalDiskToPartition\r\n\t$LogicalDisks=gwmi Win32_LogicalDisk\r\n\tForeach ($Device in $USBDrives){\r\n\t\t$DiskPhysicalDrive=\"PHYSICALDRIVE\" + \"$($Device.Index)\"\r\n\t\t$DriveToPartition=$DriveToPartitionMappings|? {$_.Antecedent -match \"$DiskPhysicalDrive\"}|%{$_.Dependent}\r\n\t\tIf($DriveToPartition -eq $null){Continue}\r\n\t\t$PartitionToLogicalDisk=$LogicalDiskMappings|?{[Object[]]$DriveToPartition -contains $_.Antecedent}\r\n\t\tIf($PartitionToLogicalDisk -eq $null){Continue}\r\n\t\t$LogicalDisk=$LogicalDisks|? {($_.Path).Path -eq ($PartitionToLogicalDisk.Dependent)}\r\n\t\tIf($LogicalDisk -ne $null){$Array += $LogicalDisk.DeviceID.substring(0,1)}\r\n\t}\r\n\tReturn $Array\r\n}",
  "callContent" : "Get-RemovableDisk",
  "subNames" : [],
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})

db.psScriptTemplate.remove({name:"Open-TargetByName"});
db.psScriptTemplate.save({
  "_id" : ObjectId("5eec72de91135503d8584d7d"),
  "name" : "Open-TargetByName",
  "desc" : "打开目标根据名称",
  "params" : [{
      "name" : "~name~",
      "defaultValue" : "",
      "type" : "String"
    }],
  "isOpen" : true,
  "content" : "Function Open-TargetByName(){\r\n    param([Parameter(Mandatory=$true, ValueFromPipeline=$true)][string[]]$name)\r\n\tFunction getLnk{\r\n\t\t$UserLnkFolder=\"$env:APPDATA\\Microsoft\\Windows\\Start Menu\\Programs\"\r\n        $MachineLnkFolder=\"$env:ProgramData\\Microsoft\\Windows\\Start Menu\\Programs\"\r\n        $lnkList1=ls -Path $UserLnkFolder -Filter \"$name.lnk\" -Recurse\r\n\t\tIf($lnkList1 -ne $null){Return $lnkList1}\r\n        Return ls -Path $MachineLnkFolder -Filter \"$name.lnk\" -Recurse\r\n\t}\r\n    Function exec ([string]$name){\r\n\t\t$lnk=getLnk\r\n\t\tIf($lnk -eq $null){Return}\r\n\t\t$LnkShortcut=(New-Object -ComObject WScript.Shell).CreateShortcut($lnk[0].FullName)\r\n\t\tIf(Test-path $LnkShortcut.TargetPath){\r\n\t\t\t$targe=gi $LnkShortcut.TargetPath\r\n\t\t\t$process=ps $targe.basename -ErrorAction SilentlyContinue\r\n\t\t\tIf($process -eq $process){ii $targe}\r\n\t\t}\r\n    }\r\n    exec $name\r\n}",
  "callContent" : "Open-TargetByName ~name~",
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})

db.psScriptTemplate.remove({name:"Get-OsVersion"});
db.psScriptTemplate.save({
  "_id" : ObjectId("5ef0614591135515e80b11a2"),
  "name" : "Get-OsVersion",
  "desc" : "获取操作系统的内核版本",
  "content" : "Function Get-OsVersion{\r\n\t$os=Get-WmiObject -Class Win32_OperatingSystem\r\n\tIf($os -eq $Null){Throw \"The operating system is empty\"}\r\n\tIf($os.version -eq $Null){Throw \"The operating system version information is empty\"}\r\n\t$vers=$os.version.split('.')\r\n\tReturn New-Object PSObject -Property @{Major=$vers[0];Minor=$vers[1];Build=$vers[2]}\r\n}",
  "callContent" : "",
  "subNames" : [],
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})

db.psScriptTemplate.remove({name:"Set-Share"});
db.psScriptTemplate.save({
  "_id" : ObjectId("5f2d13659113555704742bcf"),
  "name" : "Set-Share",
  "desc" : "启用或禁用共享配置",
  "params" : [{
      "name" : "~switch~",
      "defaultValue" : "enable",
      "type" : "String"
    }],
  "isOpen" : true,
  "content" : "Function Set-Share([Switch] $enable,[Switch] $disable){\r\n\tIf(!$enable -and !$disable){throw \"Please enter enable or disable\"}\r\n\t$svcName='LanmanServer'\r\n\t$server=Get-Service $svcName -ErrorAction SilentlyContinue\r\n\tIf($enable){\r\n\t\tIf(!$server){throw \"There is no shared service in the system , Please install this service first\"}\r\n\t\tIf($server.StartType -ne 'Automatic'){Set-Service $svcName -StartupType Automatic -ErrorAction SilentlyContinue}\r\n\t\tIf($server.status -ne 'Running'){Start-Service $svcName}\r\n\t}Else{\r\n\t\tIf(!$server){return \"There is no shared service in the system , not need oprate\"}\r\n\t\tIf($server.StartType -ne 'Disabled'){Set-Service $svcName -StartupType Disabled -ErrorAction SilentlyContinue}\r\n\t\tIf($server.status -ne 'Stopped'){Stop-Service $svcName}\r\n\t}\r\n\tRet-Success\r\n}",
  "callContent" : "Set-Share ~switch~",
  "subNames" : ["Ret-Success"],
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})
db.psScriptTemplate.remove({name:"Enable-Share"});
db.psScriptTemplate.save({
  "_id" : ObjectId("5f2d1fc59113555704742bd0"),
  "name" : "Enable-Share",
  "desc" : "启用共享配置",
  "params" : [],
  "isOpen" : true,
  "content" : "Function Enable-Share{\r\n\tTrap{Return Unified-Return $_.Exception.Message 'Enable-Share'}\r\n\tUnified-Return (Set-Share -enable) 'Enable-Share'\r\n}",
  "callContent" : "Enable-Share",
  "subNames" : ["Unified-Return","Set-Share"],
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})

db.psScriptTemplate.remove({name:"Disable-Share"});
db.psScriptTemplate.save({
  "_id" : ObjectId("5f2d229e9113555704742bd7"),
  "name" : "Disable-Share",
  "desc" : "启用共享配置",
  "params" : [],
  "isOpen" : true,
  "content" : "Function Disable-Share{\r\n\tTrap{Return Unified-Return $_.Exception.Message 'Disable-Share'}\r\n\tUnified-Return (Set-Share -disable) 'Disable-Share'\r\n}",
  "callContent" : "Disable-Share",
  "subNames" : ["Unified-Return","Set-Share"],
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})

db.psScriptTemplate.remove({name:"Set-PeripheralStatus"});
db.psScriptTemplate.save({
  "_id" : ObjectId("5f3116f09113555704742bff"),
  "name" : "Set-PeripheralStatus",
  "desc" : "启用或禁用可移动存储磁盘",
  "params" : [{
      "name" : "~status~",
      "defaultValue" : "Enable",
      "type" : "String"
    }],
  "isOpen" : true,
  "content" : "Function Set-PeripheralStatus($status){\r\n\tCheck-OperateStatus $status -ErrorAction SilentlyContinue\r\n\tIf(!$?){Return Print-Exception \"Set-PeripheralStatus\"}\r\n\t\r\n\t#启用或禁用设备实体\r\n\tSet-RemovableDiskIns $status -ErrorAction SilentlyContinue\r\n\t\r\n\t#启用或禁用[驱动,服务]\r\n\t$msg=Set-RemovableDiskDrive $status -ErrorAction SilentlyContinue\r\n\t\r\n\tIf(!$?){$msg}Else{\"$msg %%SMP:success\"}\r\n}",
  "callContent" : "Set-PeripheralStatus ~status~",
  "subNames" : ["Check-OperateStatus", "Set-RemovableDiskIns", "Set-RemovableDiskDrive"],
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})

db.psScriptTemplate.remove({name:"Check-OperateStatus"});
db.psScriptTemplate.save({
  "_id" : ObjectId("5f3118799113555704742c02"),
  "name" : "Check-OperateStatus",
  "desc" : "校验入参是否合法",
  "params" : [{
      "name" : "~status~",
      "defaultValue" : "Enable",
      "type" : "String"
    }],
  "isOpen" : true,
  "content" : "Function Check-OperateStatus($status){\r\n\tIf(@('Disable','Enable') -notcontains $status ){throw \"Illegal flag for peripheral operation. The correct flag is [Disable, Enable]\"}\r\n}",
  "callContent" : "Check-OperateStatus ~status~",
  "subNames" : [],
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})

db.psScriptTemplate.remove({name:"Set-RemovableDiskIns"});
db.psScriptTemplate.save({
  "_id" : ObjectId("5f31193e9113555704742c04"),
  "name" : "Set-RemovableDiskIns",
  "desc" : "启用或禁用可移动磁盘实体",
  "params" : [{
      "name" : "~status~",
      "defaultValue" : "Enable",
      "type" : "String"
    }],
  "isOpen" : true,
  "content" : "Function Set-RemovableDiskIns($status){\r\n\tCheck-OperateStatus $status\r\n\t\r\n\t#内核版本低于5,跳过\r\n\tIf($PSVersionTable.BuildVersion.Major -le 5){Return}\r\n\t\r\n\t#ps5.0以上版本\r\n\tIf($PSVersionTable.PSVersion.Major -ge 5){\r\n\t\tReturn Set-RemovableDiskInsForPs5 $status -ErrorAction SilentlyContinue\r\n\t}\r\n\r\n\t#获取设备实体\r\n\t$RemovableDisk=Get-RemovableDiskIns\r\n\tIf($RemovableDisk -eq $null -Or $RemovableDisk.count -eq 0){Return \"There is no removable disk connected to the system %%SMP:success\"}\r\n\t#启用或禁用设备实体\r\n\tForeach($rem In $RemovableDisk){\r\n\t\tgwmi Win32_Volume|？DriveLetter -And  DriveLetter.substring(0,1) -eq $rem|%{\r\n\t\t\tIf('Enable' -eq $flag){\r\n\t\t\t\t#启用设备实体 TODO\r\n\t\t\t\t$null=$_.AddMountPoint($diskCharacter)\r\n\t\t\t}ELse{\r\n\t\t\t\t#禁用设备实体\r\n\t\t\t\t$_.DriveLetter=$null;\r\n\t\t\t\t$null=$_.Put();\r\n\t\t\t\t$null=$_.Dismount($false, $false)\r\n\t\t\t}\r\n\t\t}\r\n\t}\r\n}",
  "callContent" : "Set-RemovableDiskIns ~status~",
  "subNames" : ["Check-OperateStatus", "Set-RemovableDiskInsForPs5", "Get-RemovableDiskIns"],
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})

db.psScriptTemplate.remove({name:"Set-RemovableDiskInsForPs5"});
db.psScriptTemplate.save({
  "_id" : ObjectId("5f3119e89113555704742c06"),
  "name" : "Set-RemovableDiskInsForPs5",
  "desc" : "启用或禁用可移动磁盘实体",
  "params" : [{
      "name" : "~status~",
      "defaultValue" : "Enable",
      "type" : "String"
    }],
  "isOpen" : true,
  "content" : "Function Set-RemovableDiskInsForPs5($status){\r\n\tCheck-OperateStatus $status\r\n\tIf('disable' -eq $status){\r\n\t\tGet-PnpDevice|?{$_.Class -eq 'WPD'  -and $_.Status -eq 'ok'}|Disable-PnpDevice -Confirm:$false\r\n\t}Else{\r\n\t\tGet-PnpDevice|?{$_.Class -eq 'WPD'  -and $_.Status -eq 'error'}|Enable-PnpDevice -Confirm:$false\r\n\t}\r\n}",
  "callContent" : "Set-RemovableDiskInsForPs5 ~status~",
  "subNames" : ["Check-OperateStatus"],
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})

db.psScriptTemplate.remove({name:"Get-RemovableDiskIns"});
db.psScriptTemplate.save({
  "_id" : ObjectId("5f311a759113555704742c08"),
  "name" : "Get-RemovableDiskIns",
  "desc" : "获取可移动磁盘实体",
  "params" : [],
  "isOpen" : true,
  "content" : "Function Get-RemovableDiskIns{\r\n\tIf($PSVersionTable.PSVersion.Major -ge 4){\r\n\t\tReturn [Object[]](Get-Disk|? BusType -eq USB|Get-Partition|Get-Volume|%{If($_.DriveLetter){$_.DriveLetter.substring(0,1)}})\r\n\t}\r\n\t$Array=@()\r\n\t$USBDrives=gwmi win32_DiskDrive|?{ $_.InterfaceType -eq 'USB' }\r\n\tIf($USBDrives -eq $null){Return $Array}\r\n\t$DriveToPartitionMappings=gwmi Win32_DiskDriveToDiskPartition|Select Antecedent,Dependent\r\n\t$LogicalDiskMappings=gwmi Win32_LogicalDiskToPartition\r\n\t$LogicalDisks=gwmi Win32_LogicalDisk\r\n\tForeach ($Device in $USBDrives){\r\n\t\t$DiskPhysicalDrive=\"PHYSICALDRIVE\" + \"$($Device.Index)\"\r\n\t\t$DriveToPartition=$DriveToPartitionMappings|? {$_.Antecedent -match \"$DiskPhysicalDrive\"}|%{$_.Dependent}\r\n\t\tIf($DriveToPartition -eq $null){Continue}\r\n\t\t$PartitionToLogicalDisk=$LogicalDiskMappings|?{[Object[]]$DriveToPartition -contains $_.Antecedent}\r\n\t\tIf($PartitionToLogicalDisk -eq $null){Continue}\r\n\t\t$LogicalDisk=$LogicalDisks|? {($_.Path).Path -eq ($PartitionToLogicalDisk.Dependent)}\r\n\t\tIf($LogicalDisk -ne $null){$Array += $LogicalDisk.DeviceID.substring(0,1)}\r\n\t}\r\n\tReturn $Array\r\n}",
  "callContent" : "Get-RemovableDiskIns",
  "subNames" : [],
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})

db.psScriptTemplate.remove({name:"Set-RemovableDiskDrive"});
db.psScriptTemplate.save({
  "_id" : ObjectId("5f311be29113555704742c0a"),
  "name" : "Set-RemovableDiskDrive",
  "desc" : "启用或禁用可移动磁盘驱动",
  "params" : [{
      "name" : "~status~",
      "defaultValue" : "Enable",
      "type" : "String"
    }],
  "isOpen" : true,
  "content" : "Function Set-RemovableDiskDrive($status){\r\n\tCheck-OperateStatus $status\r\n\r\n\t$osVer = (Get-WmiObject Win32_OperatingSystem).caption\r\n\tIf($osVer -ne \"Microsoft Windows 7 Enterprise\"){\r\n\t\tIf (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] \"Administrator\")){   \r\n\t\t\t$arguments = \"& '\" + $myinvocation.mycommand.definition + \"'\"\r\n\t\t\tStart-Process powershell -Verb runAs -ArgumentList $arguments\r\n\t\t\tBreak\r\n\t\t}\r\n\t}\r\n\r\n\t$usb_Reg=\"HKLM:\\SYSTEM\\CurrentControlSet\\services\\USBSTOR\"\r\n\tIf(!(Test-Path $usb_Reg)){$Null=md $usb_Reg -Force}\r\n\t$usb_State = Get-ItemProperty $usb_Reg\r\n\t$cdDvd_reg=\"HKLM:\\SYSTEM\\CurrentControlSet\\services\\cdrom\"\r\n\tIf(!(Test-Path $cdDvd_reg)){$Null=md $cdDvd_reg -Force}\r\n\t$cdDvdRom_State = Get-ItemProperty $cdDvd_reg\r\n\t$storageDev=\"HKLM:\\Software\\Policies\\Microsoft\\Windows\\RemovableStorageDevices\"\r\n\t$msg=@();\r\n\tIf(\"Enable\" -eq $status){\r\n\t\t$msg+=\"Enabling USB Storage...\"\r\n\t\tIf($usb_State.start -ne 3){Set-ItemProperty $usb_Reg -Name start -Value 3}\r\n\t\tStart-Sleep -Seconds 1\r\n\t\t$msg+=\"Enabling CD/DVD ROM...\"\r\n\t\tIf($cdDvdRom_State.start -ne 1){Set-ItemProperty $cdDvd_reg -Name start -Value 1}\r\n\t\t$msg+=\"Enabling Card Readers...\"\r\n\t\tRemove-ItemProperty $storageDev -Name Deny_All -Force -ErrorAction SilentlyContinue ; \r\n\t}Else{\r\n\t\t$msg+=\"Disabling USB Storage...\"\r\n\t\tIf($usb_State.start -ne 4){Set-ItemProperty $usb_Reg -Name start -Value 4}\r\n\t\tStart-Sleep -Seconds 1\r\n\t\t$msg+=\"Disabling CD/DVD ROM...\"\r\n\t\tIf($cdDvdRom_State.start -ne 4){Set-ItemProperty $cdDvd_reg -Name start -Value 4}\r\n\t\t$msg+=\"Disabling Card Readers...\"\r\n\t\tIf(!(Test-Path $storageDev)){$Null=md $storageDev -Force -ErrorAction SilentlyContinue}\r\n\t\t$Null=New-ItemProperty $storageDev -Name Deny_All -Value 1 -PropertyType DWORD\r\n\t}\r\n\tReturn $msg\r\n}",
  "callContent" : "Set-RemovableDiskDrive ~status~",
  "subNames" : ["Check-OperateStatus"],
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})

db.psScriptTemplate.remove({name:"Config-Plugin"});
db.psScriptTemplate.save({
  "_id" : ObjectId("5f8d295491135534fcc16b58"),
  "name" : "Config-Plugin",
  "desc" : "配置插件",
  "params" : [{
      "userName" : "$null",
      "name" : "~userName~",
      "type" : "String"
    }, {
      "password" : "$null",
      "name" : "~password~",
      "type" : "String"
    }, {
      "canUninstallPlugin" : "false",
      "name" : "~canUninstallPlugin~",
      "type" : "String"
    }, {
      "uninstallPassword" : "$null",
      "name" : "~uninstallPassword~",
      "type" : "String"
    }],
  "isOpen" : true,
  "content" : "Function Config-Plugin{\r\n\tParam(\r\n\t\t[String]$userName=$null,\r\n\t\t[String]$password=$null,\r\n\t\t[String]$uninstallPassword=$null,\r\n\t\t[String]$canUninstallPlugin='false'\r\n\t)\r\n\t$installDir=$env:ProgramFiles\r\n\t#If([IntPtr]::Size -eq 8){$installDir+=' (x86)'}\r\n\t$configPath=Join-Path $installDir 'Ruijie Networks/pluginUninstall'\r\n\t$hashtable = @{}\r\n\tIf(Test-Path $configPath){\r\n\t\tcat -Path $configPath|?{ $_ -like '*=*' }|%{\r\n\t\t\t$info = $_ -split '='\r\n\t\t\t$hashtable.$($info[0].Trim()) = $info[1].Trim()\r\n\t\t}\r\n\t\tclc $configPath\r\n\t}\r\n\t$ParameterList = (gcm -Name $MyInvocation.InvocationName).Parameters\r\n\tForeach ($key in $ParameterList.keys){\r\n\t\t$var = gv $key -ErrorAction SilentlyContinue\r\n\t\t$hashtable.$key=$var.value\r\n\t}\r\n\tForeach($key in $hashtable.Keys){\"$key=$($hashtable.$key)\" | Out-File $configPath -Encoding utf8 -Append}\r\n}",
  "callContent" : "Config-Plugin -userName ~userName~ -password ~password~ -uninstallPassword ~uninstallPassword~ -canUninstallPlugin ~canUninstallPlugin~",
  "subNames" : [],
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})

db.psScriptTemplate.remove({name:"Config-TightVNC"});
db.psScriptTemplate.save({
  "_id" : ObjectId("5fbf65239113554f546e525c"),
  "name" : "Config-TightVNC",
  "desc" : "配置TightVNC",
  "content" : "Function Config-TightVNC{\r\n\tParam(\r\n\t\t[Parameter(Mandatory=$true)]$RegPath,[bool]$IsReplace=$True,[String]$Password,[String]$ControlPassword,[String]$PasswordViewOnly,\r\n\t\t[String]$QueryTimeout,[String]$ExtraPorts,[String]$QueryAcceptOnTimeout,[String]$LocalInputPriorityTimeout,[String]$LocalInputPriority,\r\n\t\t[String]$BlockRemoteInput,[String]$BlockLocalInput,[String]$IpAccessControl,[String]$RfbPort,[String]$HttpPort,[String]$DisconnectAction,\r\n\t\t[String]$AcceptRfbConnections,[String]$UseVncAuthentication,[String]$UseControlAuthentication,[String]$RepeatControlAuthentication,\r\n\t\t[String]$LoopbackOnly,[String]$AcceptHttpConnections,[String]$LogLevel,[String]$EnableFileTransfers,[String]$RemoveWallpaper,[String]$UseMirrorDriver,\r\n\t\t[String]$EnableUrlParams,[String]$AlwaysShared,[String]$NeverShared,[String]$DisconnectClients,[String]$PollingInterval,[String]$AllowLoopback,\r\n\t\t[String]$VideoRecognitionInterval,[String]$GrabTransparentWindows,[String]$SaveLogToAllUsersPath,[String]$RunControlInterface\r\n\t)\r\n\t\t\r\n\t$DefautV=@{\r\n\t\tPassword='Binary:@(15,224,193,197,37,128,73,235)';ControlPassword='Binary:@(15,224,193,197,37,128,73,235)';PasswordViewOnly='Binary:@(15,224,193,197,37,128,73,235)';\r\n\t\tQueryTimeout='Dword:30';ExtraPorts='String:';QueryAcceptOnTimeout='Dword:0';\r\n\t\tLocalInputPriorityTimeout='Dword:3';LocalInputPriority='Dword:0';BlockRemoteInput='Dword:0';\r\n\t\tBlockLocalInput='Dword:0';IpAccessControl='String:';RfbPort='Dword:5900';\r\n\t\tHttpPort='Dword:5800';DisconnectAction='Dword:0';AcceptRfbConnections='Dword:1';\r\n\t\tUseVncAuthentication='Dword:1';UseControlAuthentication='Dword:1';RepeatControlAuthentication='Dword:0';\r\n\t\tLoopbackOnly='Dword:0';AcceptHttpConnections='Dword:1';LogLevel='Dword:0';\r\n\t\tEnableFileTransfers='Dword:1';RemoveWallpaper='Dword:1';UseMirrorDriver='Dword:1';\r\n\t\tEnableUrlParams='Dword:1';AlwaysShared='Dword:0';NeverShared='Dword:0';\r\n\t\tDisconnectClients='Dword:1';PollingInterval='Dword:1000';AllowLoopback='Dword:0';\r\n\t\tVideoRecognitionInterval='Dword:3000';GrabTransparentWindows='Dword:1';SaveLogToAllUsersPath='Dword:0';\r\n\t\tRunControlInterface='Dword:1'\r\n\t}\r\n\t\r\n\tIf(!(Test-Path $RegPath)){$null=md $RegPath -Force -ErrorAction SilentlyContinue}\r\n\t$reg=gi $RegPath\r\n\t$pks=$PSBoundParameters.keys\r\n\tForeach($pk in $pks){\r\n\t\t$dm=$DefautV.$pk\r\n\t\tIf(!$dm){Continue}\r\n\t\t$DefautV.remove($pk)\r\n\t\t$pv=$PSBoundParameters[$pk]\r\n\t\t$rv=$reg.GetValue($pk)\r\n\t\t$dt=$dm.split(':')[0]\r\n\t\tIf('Binary' -eq $dt){\r\n\t\t\tIf($rv -eq $null){$rv=''}\r\n\t\t\tIf($pv -eq ($rv -join '-')){Continue}\r\n\t\t\t$pv=$pv.split('-')\r\n\t\t}Else{If($pv -eq $rv){Continue}}\r\n\t\tIf($IsReplace){sp $RegPath -Name $pk -Value $pv -Type $dt}\r\n\t}\r\n\t\r\n\t$dks=$DefautV.keys\r\n\tForeach($dk in $dks){\r\n\t\tIf($reg.GetValue($dk)){Continue}\r\n\t\t$str=$DefautV.$dk\r\n\t\t$arr=$str.split(':')\r\n\t\tIf($arr.count -ne 2){continue}\r\n\t\t$dt=$arr[0]\r\n\t\t$dv=$arr[1]\r\n\t\tIf('Binary' -eq $dt){$dv=iex \"$($arr[1])\"}\r\n\t\tsp $RegPath -Name $dk -Value $dv -Type $dt\r\n\t\t$IsChange=$true\r\n\t}\r\n}",
  "callContent" : "",
  "subNames" : [],
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})

db.psScriptTemplate.remove({name:"Ret-Processing"});
db.psScriptTemplate.save({
  "_id" : ObjectId("600507e0911355582c1f6743"),
  "name" : "Ret-Processing",
  "desc" : "校验资源是否在处理中",
  "params" : [{
      "name" : "~business~",
      "defaultValue" : "$null"
    }],
  "content" : "Function Ret-Processing($business){\r\n\tReturn \"$business%%SMP:processing\"\r\n}",
  "callContent" : "Ret-Processing ~business~",
  "subNames" : [],
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})

db.psScriptTemplate.remove({name:"Check-Processing"});
db.psScriptTemplate.save({
  "_id" : ObjectId("60015b8a911355582c1f6732"),
  "name" : "Check-Processing",
  "desc" : "校验资源是否在处理中",
  "params" : [{
      "name" : "~path~",
      "defaultValue" : "$null"
    }],
  "content" : "Function Check-Processing([String]$path,[System.IO.FileInfo]$file){\r\n\tIf($file -eq $null){\r\n\t\tIf(!(Test-Path $path)){Return \"The path [$path] does not exist\"}\r\n\t\t$file=ls $path\t\r\n\t}\t\r\n\t$process=ps|?{$_.name -eq $file.baseName -And ($_.path -eq $null -Or $_.path -eq $file.FullName)}\r\n\tIf($process -ne $null){Return Ret-Processing \"$($file.fullname) is Installing\"}\r\n\tReturn Ret-Success\r\n}",
  "callContent" : "Check-Processing ~path~",
  "subNames" : ["Ret-Success"],
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})

db.psScriptTemplate.remove({name:"OperatorSoftwareByMSI"});
db.psScriptTemplate.save({
  "_id" : ObjectId("6004fc00911355582c1f673f"),
  "name" : "OperatorSoftwareByMSI",
  "desc" : "通过msiexec安装或卸载软件",
  "content" : "Function OperatorSoftwareByMSI{\r\n\tparam(\r\n\t\t[String]$softwarePath,\r\n\t\t[ValidateSet('install','package','i','uninstall','x')]$method,\r\n\t\t$isSilent=$false\r\n\t)\r\n\tIf([String]::IsNullOrEmpty(\"$softwarePath\")){\r\n\t\tReturn \"Executable file [${softwarePath}] does not exist\"\r\n\t}\r\n\t$business=\"OperatorSoftwareByMSI of `\"$softwarePath`\"\"\r\n\t$power=gwmi Win32_Process|?{$_.ProcessName -eq \"msiexec.exe\"}|%{ps -id $_.ParentProcessId -ErrorAction SilentlyContinue}|?{$_.name -eq 'cmd'}\r\n\tIf($power -ne $null){Return Ret-Processing \"$softwarePath is Installing\"}\r\n\t\r\n\tIf(@('install','package','i') -contains $method){\r\n\t\t$command=\"& cmd /c `'msiexec.exe /i `\"$softwarePath`\"`' /norestart /qn ADVANCED_OPTIONS=1 CHANNEL=100\"\r\n\t}Elseif(@('uninstall','x') -contains $method){\r\n\t\t$command=\"& cmd /c `'msiexec.exe /x `\"$softwarePath`\"`' /norestart ADVANCED_OPTIONS=1 CHANNEL=100\"\r\n\t}Else{Return 'Method not supported'}\r\n\t\r\n\t$null=iex $command -ErrorAction SilentlyContinue\r\n\tIf(!$?){Return Print-Exception $business}\r\n\tReturn Ret-Success $business\r\n}",
  "callContent" : "OperatorSoftwareByMSI ~softwarePath~ ~method~ ~isSilent~",
  "subNames" : ["Ret-Success", "Ret-Processing", "Print-Exception"],
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})

db.psScriptTemplate.remove({name:"System-Patch"});
db.psScriptTemplate.save({
  "_id" : ObjectId("5e68a0da15861178cf329ea6"),
  "name" : "System-Patch",
  "desc" : "系统补丁脚本模板",
  "params" : [{
      "name" : "~hostUrl~",
      "defaultValue" : "$null"
    }, {
      "name" : "~fileName~",
      "defaultValue" : "$null"
    }, {
      "name" : "~osArchitecture~",
      "defaultValue" : "$null"
    }, {
      "name" : "~adapterProducts~",
      "defaultValue" : "$null"
    }, {
      "name" : "~kbNum~",
      "defaultValue" : "$null"
    }],
  "analyzingContent" : "package com.ruijie.authentication.session.program.domain.program;\r\ndialect  \"java\"\r\nimport com.ruijie.authentication.session.program.domain.program.PsScriptTemplateAnalyzingProcedureFact\r\nimport com.ruijie.authentication.authnode.domain.node.compliance.ComplianceDetectingResultState\r\nrule \"compliance\"\r\nwhen\r\n\tfact:PsScriptTemplateAnalyzingProcedureFact()\r\nthen\r\n\tfact.setResponse(fact.getScriptResponse().getResponse());\r\n\tfact.setOperateRecord(fact.getScriptResponse().getResponse());\r\n\tif(fact.getScriptResponse().isTimeout()==true){\r\n\t\tfact.setResultState(ComplianceDetectingResultState.COMPLIANCE_FAIL);\r\n\t\tfact.setResponse(\"script execution timeout\");\r\n\t}else if(fact.getScriptResponse().getResponse().endsWith(\"%%SMP:processing\")){\r\n\t\tfact.setResultState(ComplianceDetectingResultState.COMPLYING);\r\n\t}else if(!fact.getScriptResponse().getResponse().endsWith(\"%%SMP:success\")){\r\n\t\tfact.setResultState(ComplianceDetectingResultState.COMPLIANCE_FAIL);\r\n\t}\r\nend",
  "content" : "Function System-Patch($hostUrl,$fileName,$osArchitecture,$adapterProducts,$kbNum){\r\n\t$os=gwmi Win32_OperatingSystem\r\n\t$isMatch=$false\r\n\tForeach($ad in $adapterProducts){If($os.Caption -like \"*${ad}*\"){$isMatch=$true;Break}}\r\n\t\r\n\tIf(!$isMatch){Return Ret-Success \"product not matched\"}\r\n\t\r\n\tIf(($osarchitecture -like '*IA*' -And $env:PROCESSOR_ARCHITECTURE -ne 'IA64') -or $os.osarchitecture -notlike \"${osArchitecture}*\"){\r\n\t\treturn Ret-Success \"osarchitecture not matched\"\r\n\t}\r\n\t\r\n\tIf(Is-KbInstalled $kbNum){Return Ret-Success \"This patch is aready installed successfully\"}\r\n\r\n\tIf([String]::isNullOrEmpty($hostUrl)){Return \"hostUrl can not empty\"}\r\n\r\n\t$downloadPath=Join-Path $env:SystemDrive '/Program Files/Ruijie Networks/systemPatches/';\r\n\tIf(!(Test-Path $downloadPath)){$null=New-Item $downloadPath -ItemType Directory -Force}\r\n\r\n\tIf([String]::isNullOrEmpty($fileName)){Return \"patch file name can not empty\"}\r\n\r\n\t$softwarePath=Join-Path $downloadPath $fileName\r\n\t$Res=Download-File \"${hostUrl}$fileName\" $softwarePath;$Res\r\n\tIf(!(Is-Success $Res)){Return}\r\n\r\n\tReturn InstallPatch $hostUrl $softwarePath $downloadPath $fileName $kbNum\r\n}",
  "callContent" : "System-Patch ~hostUrl~ ~fileName~ ~osArchitecture~ ~adapterProducts~ ~kbNum~",
  "subNames" : ["Print-Exception", "expandMsu", "InstallPatch-ByDism", "InstallPatch", "Is-KbInstalled", "Is-Success", "Ret-Success", "Check-Processing", "OperatorSoftwareBySWI"],
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})

db.psScriptTemplate.remove({name:"Is-KbInstalled"});
db.psScriptTemplate.save({
  "_id" : ObjectId("6046f9039113550104a7ac29"),
  "name" : "Is-KbInstalled",
  "desc" : "根据KB号校验补丁是否已安装",
  "isOpen" : true,
  "content" : "Function Is-KbInstalled($kbNum){\r\n\t$qfe=wmic qfe get HotFixID\r\n\tIf($qfe|?{$_ -like \"KB${kbNum}*\"}){Return $true}\r\n\tIf(($qfe|select -first 1) -like 'HotFixID*'){Return $false}\r\n\t\r\n\t$Key='SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Component Based Servicing\\Packages';\r\n\t$RegHive=[Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine',$env:COMPUTERNAME);\r\n\t$RegKey=$RegHive.OpenSubKey($Key);\r\n\tIf([string]::IsNullOrEmpty($RegKey)){Return $false}\r\n\t$names=$RegKey.GetSubKeyNames()\r\n\t$matched=$false\r\n\tForEach($_ in $names){\r\n\t\tIf($_ -match \"Package_for_KB${kbNum}~[a-zA-Z0-9]*~[a-zA-Z0-9]*~~\"){\r\n\t\t\t$matched=$true\r\n\t\t\t$SubKey=$RegKey.OpenSubKey($_);\r\n\t\t\t$tmp=$subkey.GetValue('CurrentState');\r\n\t\t\t$SubKey.Close()\r\n\t\t\tIf($tmp.gettype().name -eq 'int32'){\r\n\t\t\t\tIf($tmp -eq 0x70 -or $tmp -eq 0x60  -or $tmp -eq 0x65 ){Return $true}\r\n\t\t\t}\r\n\t\t}\r\n\t}\r\n\t\r\n\tIf(!$matched){\r\n\t\tForEach($_ in $names){\r\n\t\t\tIf($_ -match \"Package_for_KB${kbNum}_RTM~[a-zA-Z0-9]*~[a-zA-Z0-9]*~~\"){\r\n\t\t\t\t$SubKey=$RegKey.OpenSubKey($_);\r\n\t\t\t\t$tmp=$subkey.GetValue('CurrentState');\r\n\t\t\t\t$SubKey.Close()\r\n\t\t\t\tIf($tmp.gettype().name -eq 'int32'){\r\n\t\t\t\t\tIf($tmp -eq 0x70 -or $tmp -eq 0x60  -or $tmp -eq 0x65 ){Return $true}\r\n\t\t\t\t}\r\n\t\t\t}\r\n\t\t}\r\n\t}\r\n\t$RegHive.Close()\r\n\treturn $false\r\n}",
  "callContent" : "Is-KbInstalled ~kbNum~",
  "params" : [],
  "analyzingContent" : "package pstemplates.openfirewall;\r\ndialect  \"mvel\"\r\n\r\nimport com.ruijie.authentication.session.program.domain.program.PsScriptTemplateAnalyzingProcedureFact;\r\nimport com.ruijie.authentication.authnode.domain.node.LabelValue;\r\nimport com.ruijie.authentication.authnode.domain.node.compliance.ComplianceDetectingResultState;\r\nimport com.ruijie.authentication.authnode.domain.label.LabelConstant;\r\n\r\nrule \"analyzingScript\"\r\n    when\r\n        $fact: PsScriptTemplateAnalyzingProcedureFact($node: node, $scriptResponse: scriptResponse, $labels: updateLabels)\r\n    then\r\n        if ($scriptResponse.isError() || $scriptResponse.isTimeout()){\r\n            $fact.setResultState(ComplianceDetectingResultState.EXCEPTION_SUFFICE);\r\n            $fact.setOperateRecord(\"执行异常或执行操作，默认合规\");\r\n        } else {\r\n           String response = $scriptResponse.getResponse();\r\n           String result = response.substring(response.indexOf(\"%%SMP:\") + 6);\r\n           if (\"detecting-suffice\".equals(result) || \"executing-suffice\".equals(result)){\r\n                $labels.put(LabelConstant.FIRE_WALL_ALL_ON, LabelValue.builder()\r\n                                        .value(true)\r\n                                        .build());\r\n                $fact.setResultState(ComplianceDetectingResultState.COMPLIANCE_SUFFICE);\r\n                $fact.setOperateRecord(\"防火墙已开启！\");\r\n           }else if(\"executing-fail\".equals(result)){\r\n                $labels.put(LabelConstant.FIRE_WALL_ALL_ON, LabelValue.builder()\r\n                                        .value(false)\r\n                                        .build());\r\n                $fact.setResultState(ComplianceDetectingResultState.COMPLIANCE_FAIL);\r\n                $fact.setOperateRecord(\"防火墙开启失败！\");\r\n           } else {\r\n                $labels.put(LabelConstant.FIRE_WALL_ALL_ON, LabelValue.builder()\r\n                                                       .value(true)\r\n                                                       .build());\r\n                $fact.setResultState(ComplianceDetectingResultState.COMPLIANCE_SUFFICE);\r\n                $fact.setOperateRecord(\"内部异常，默认合规！\");\r\n           }\r\n        }\r\nend\r\n",
  "_version_" : NumberLong(0),
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})

db.psScriptTemplate.remove({name:"InstallPatch-ByDism"});
db.psScriptTemplate.save({
  "_id" : ObjectId("60584ac19113553d4c546f21"),
  "name" : "InstallPatch-ByDism",
  "desc" : "使用dism安装补丁",
  "content" : "Function InstallPatch-ByDism($path,$kbNum){\r\n\tIf(ps dism -ErrorAction SilentlyContinue){Return Ret-Processing \"Installing patch $kbNum by dism\"}\r\n\tTry{\r\n\t\t$null=.\\dism.exe /online /add-package /packagepath:\"$path\" /quiet /norestart\r\n\t\tIf($LASTEXITCODE -eq 0 ){\r\n\t\t\tReturn Ret-Success \"dism add package success\"\r\n\t\t}Elseif($LASTEXITCODE -eq -2146498530){\r\n\t\t\tReturn Ret-Success \"The specified package is not applicable to this image\"\r\n\t\t}Elseif($LASTEXITCODE -eq 3010){\r\n\t\t\tReturn Ret-Success \"reboot system is required\"\r\n\t\t}Elseif($LASTEXITCODE -eq 3){\r\n\t\t\tReturn \"file path can not be found\"\r\n\t\t}Elseif($LASTEXITCODE -eq 183){\r\n\t\t\tReturn Ret-Success \"The specified package is not applicable to this image\"\r\n\t\t}Else{\r\n\t\t\tIf(Is-KbInstalled $kbNum){Return Ret-Success \"This patch is aready installed successfully\"}\r\n\t\t\tReturn \"unknown error, exit code is \"+$LASTEXITCODE\r\n\t\t}\r\n\t}Catch{\r\n\t\tIf($error[0] -like '*not applicable to this image*'){Return Ret-Success $error[0]}\r\n\t\tElse{Return $error[0]}\r\n\t}\r\n}",
  "callContent" : "",
  "subNames" : ["Ret-Success","Is-KbInstalled", "Ret-Processing"],
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})

db.psScriptTemplate.remove({name:"InstallPatch"});
db.psScriptTemplate.save({
  "_id" : ObjectId("60584ab79113553d4c546f1f"),
  "name" : "InstallPatch",
  "desc" : "安装补丁",
  "content" : "Function InstallPatch($hostUrl,$softwarePath,$downloadPath,$fileName,$kbNum){\r\n\t$Suffix=(gi -Path $softwarePath).Extension\r\n\tIf(@('.exe','.cab','.msu') -notcontains $Suffix){Return \"Installation of [$fileName] is not supported\"}\r\n\t\r\n\tIf('.exe' -eq $Suffix){Return OperatorSoftwareBySWI $hostUrl $softwarePath $true}\r\n\t\r\n\tcd (Join-Path $env:SystemRoot 'system32')\r\n\tIf('.msu' -eq $Suffix){\r\n\t\t#校验锁\r\n\t\t$lockPath=Join-Path $downloadPath \"${kbNum}_lock\"\r\n\t\tIf(Test-Path $lockPath){\r\n\t\t\t$date=(gi $lockPath).LastWriteTime\r\n\t\t\t$now=Get-date\r\n\t\t\tIf($date.AddMinutes(30) -ge $now){\r\n\t\t\t\tIf($date.AddMinutes(3) -le $now){\r\n\t\t\t\t\tIf(ps dism -ErrorAction SilentlyContinue){Return Ret-Processing \"Installing patch $kbNum by dism\"}\r\n\t\t\t\t}Else{\r\n\t\t\t\t\tReturn Ret-Processing \"the patch of [KB$kbNum] is being installed. Please try again later\"\r\n\t\t\t\t}\r\n\t\t\t}\r\n\t\t\trm $lockPath -Force\r\n\t\t}\r\n\t\t\r\n\t\t#加锁\r\n\t\t$null=ni $lockPath -Force\r\n\t\t\r\n\t\t$res=ExpandAndInstall-ByDism $fileName $downloadPath $softwarePath\r\n\r\n\t\t#删除锁\r\n\t\t$null=rm $lockPath -Force\r\n\t\tReturn $res\r\n\t}\r\n\tReturn InstallPatch-ByDism $softwarePath $kbNum\r\n}",
  "callContent" : "",
  "subNames" : ["expandMsu", "Ret-Success", "InstallPatch-ByDism", "ExpandAndInstall-ByDism","Ret-Processing", "OperatorSoftwareBySWI"],
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})

db.psScriptTemplate.remove({name:"ExpandAndInstall-ByDism"});
db.psScriptTemplate.save({
  "_id" : ObjectId("6063d296911355d6706f32c4"),
  "name" : "ExpandAndInstall-ByDism",
  "desc" : "解压补丁包并通过DISM安装补丁",
  "content" : "Function ExpandAndInstall-ByDism($fileName,$downloadPath,$softwarePath){\r\n\t$ret=expandMsu $fileName $downloadPath $softwarePath\r\n\tIf(!$ret[0]){Return $ret[1]}\r\n\t$softwarePath=$ret[1]\r\n\tReturn InstallPatch-ByDism $softwarePath $kbNum\r\n}",
  "callContent" : "",
  "params" : [],
  "analyzingContent" : "package pstemplates.openfirewall;\r\ndialect  \"mvel\"\r\n\r\nimport com.ruijie.authentication.session.program.domain.program.PsScriptTemplateAnalyzingProcedureFact;\r\nimport com.ruijie.authentication.authnode.domain.node.LabelValue;\r\nimport com.ruijie.authentication.authnode.domain.node.compliance.ComplianceDetectingResultState;\r\nimport com.ruijie.authentication.authnode.domain.label.LabelConstant;\r\n\r\nrule \"analyzingScript\"\r\n    when\r\n        $fact: PsScriptTemplateAnalyzingProcedureFact($node: node, $scriptResponse: scriptResponse, $labels: updateLabels)\r\n    then\r\n        if ($scriptResponse.isError() || $scriptResponse.isTimeout()){\r\n            $fact.setResultState(ComplianceDetectingResultState.EXCEPTION_SUFFICE);\r\n            $fact.setOperateRecord(\"执行异常或执行操作，默认合规\");\r\n        } else {\r\n           String response = $scriptResponse.getResponse();\r\n           String result = response.substring(response.indexOf(\"%%SMP:\") + 6);\r\n           if (\"detecting-suffice\".equals(result) || \"executing-suffice\".equals(result)){\r\n                $labels.put(LabelConstant.FIRE_WALL_ALL_ON, LabelValue.builder()\r\n                                        .value(true)\r\n                                        .build());\r\n                $fact.setResultState(ComplianceDetectingResultState.COMPLIANCE_SUFFICE);\r\n                $fact.setOperateRecord(\"防火墙已开启！\");\r\n           }else if(\"executing-fail\".equals(result)){\r\n                $labels.put(LabelConstant.FIRE_WALL_ALL_ON, LabelValue.builder()\r\n                                        .value(false)\r\n                                        .build());\r\n                $fact.setResultState(ComplianceDetectingResultState.COMPLIANCE_FAIL);\r\n                $fact.setOperateRecord(\"防火墙开启失败！\");\r\n           } else {\r\n                $labels.put(LabelConstant.FIRE_WALL_ALL_ON, LabelValue.builder()\r\n                                                       .value(true)\r\n                                                       .build());\r\n                $fact.setResultState(ComplianceDetectingResultState.COMPLIANCE_SUFFICE);\r\n                $fact.setOperateRecord(\"内部异常，默认合规！\");\r\n           }\r\n        }\r\nend\r\n",
  "_version_" : NumberLong(0),
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})

db.psScriptTemplate.remove({name:"expandMsu"});
db.psScriptTemplate.save({
  "_id" : ObjectId("60584ac69113553d4c546f23"),
  "name" : "expandMsu",
  "desc" : "解压msc文件",
  "content" : "Function expandMsu($fileName,$src,$des){\r\n\tIf($fileName.Split(\"_\").Count -eq 1){\r\n\t\t$expandFolder=$src + $fileName.Substring(0, $fileName.LastIndexOf('.'))\r\n\t}Else{\r\n\t\t$expandFolder=$src + $fileName.Split(\"_\")[0]\r\n\t}\r\n\tIf(Test-Path $expandFolder){\r\n\t\ttry{rm $expandFolder -Recurse -Force -ErrorAction Stop}catch{Return @($false,(Ret-Processing \"Installing patch, please wait a moment.\"))}}\r\n\t$null=mkdir $expandFolder -Force\r\n\t$null=.\\expand -F:* $des $expandFolder\r\n\tReturn @($true,(ls $expandFolder|?{$_.Extension -eq '.cab' -and $_.name -notlike \"*WSUSSCAN.cab\"}|Select -First 1|%{$_.FullName}))\r\n}",
  "callContent" : "",
  "subNames" : ["Ret-Success", "Ret-Processing"],
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})

/*PowerShell脚本模板--end*/