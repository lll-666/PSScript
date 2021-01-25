db.psScriptTemplate.remove({});
db.psScriptTemplate.save([
{
  "name" : "Get-InstalledSoftware",
  "desc" : "收集终端软件信息",
  "content" : "Function Get-InstalledSoftware{\r\n\t$Key='Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall','SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall';\r\n\tIf([IntPtr]::Size -eq 8){\r\n\t   $Key+='SOFTWARE\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall'\r\n\t}\r\n\t$Value='DisplayName','DisplayVersion','UninstallString','InstallLocation','RegPath','EstimatedSize','InstallDate','InstallSource','Language','ModifyPath','Publisher','icon';\r\n\tForeach($_ in $Key){\r\n\t  $Hive='LocalMachine';\r\n\t  If('Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall' -ceq $_){$Hive='CurrentUser'}\r\n\t  $RegHive=[Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($Hive,$env:COMPUTERNAME);\r\n\t  $RegKey=$RegHive.OpenSubKey($_);\r\n\t  If([string]::IsNullOrEmpty($RegKey)){Continue}\r\n\t  $RegKey.GetSubKeyNames()|ForEach{\r\n\t\t$SubKey=$RegKey.OpenSubKey($_);\r\n\t\t$retVal=1|Select-Object -Property $Value;\r\n\t\tForEach($_ in $Value){\r\n\t\t\t$tmp=$subkey.GetValue($_);\r\n\t\t\tIf(![string]::IsNullOrEmpty($tmp)){\r\n\t\t\t\tIf($tmp.gettype().name -eq 'string'){\r\n\t\t\t\t\t$retVal.$_=($tmp -replace [Regex]::UnEscape('\\u0000'), '').Replace('\"','').Replace('\\','/')\r\n\t\t\t\t}Elseif($tmp.gettype().name -eq 'int32'){\r\n\t\t\t\t\t$retVal.$_=$tmp\r\n\t\t\t\t}\r\n\t\t\t}\r\n\t\t};\r\n\t\tIf(![string]::IsNullOrEmpty($SubKey.GetValue('DisplayName'))){\r\n\t\t\t$tmp=$SubKey.Name;\r\n\t\t\tIf(![string]::IsNullOrEmpty($tmp)){\r\n\t\t\t\t$retVal.RegPath=($tmp -replace [Regex]::UnEscape('\\u0000'), '').Replace('\"','').Replace('\\','/')\r\n\t\t\t}\r\n\t\t\t$retVal\r\n\t\t}\r\n\t\t$SubKey.Close()\r\n\t  };\r\n\t  $RegHive.Close()\r\n\t}\r\n}",
  "callContent" : "Get-InstalledSoftware|ConvertTo-Csv|Select -Skip 1",
  "subNames" : []
},{
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
      "defaultValue" : "$null"
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
  "content" : "Function White-Software($hostUrl,$softwareName,$softwareVersion,$fileName64,$fileName32,$isRun,$processName,$serviceName){\r\n\t$business=\"[Install $softwareName]=>>\";\r\n\tIf([String]::isNullOrEmpty($softwareName)){Return \"BusinessException:softwareName can not empty\"}\r\n\tIf((Get-SoftwareInfoByNameVersion $softwareName $softwareVersion) -ne $null){\r\n\t\tIf(!$isRun){Return Ret-Success $business}\r\n\t\tIf([String]::isNullOrEmpty($serviceName) -and [String]::isNullOrEmpty($processName)){\r\n\t\t\tReturn \"BusinessException:The software needs to be opened. The process name and service name cannot both be empty\"\r\n\t\t}\r\n\t\tIf(![String]::isNullOrEmpty($serviceName)){\r\n\t\t\t$Res = Set-Serviced $serviceName 'Automatic' 'Running';\"$business$Res\";\r\n\t\t\tIf(Is-Success $Res){Return}\r\n\t\t}\r\n\t\tIf(![String]::isNullOrEmpty($processName)){\r\n\t\t\t$Res = Set-Processd $processName $true $null;\"$business$Res\";\r\n\t\t\tIf(Is-Success $Res){Return}\r\n\t\t}\r\n\t}\r\n\r\n\tIf([String]::isNullOrEmpty($hostUrl)){Return \"BusinessException:hostUrl can not empty\"}\r\n\tIf([String]::isNullOrEmpty($fileName64) -and [String]::isNullOrEmpty($fileName32)){Return \"BusinessException:install package can not empty\"}\r\n\r\n\t$downloadPath = Join-Path $env:SystemDrive '/Program Files/Ruijie Networks/softwarePackage/';\r\n\tIf(!(Test-Path $downloadPath)){mkdir $downloadPath -Force|Out-Null}\r\n\r\n\tIf([IntPtr]::Size -eq 8 -and ![String]::isNullOrEmpty($fileName64)){\r\n\t\t$bit='bit64';\r\n\t\t$fileName=$fileName64;\r\n\t}Else{\r\n\t\t$bit='bit32';\r\n\t\t$fileName=$fileName32\r\n\t}\r\n\r\n\t$softwarePath = Join-Path $downloadPath $fileName;\r\n\tIf(!(Test-Path \"$softwarePath\") -or (Get-Content \"$softwarePath\" -TotalCount 1) -eq $null){\r\n\t\t$remoteSoftwarePath=$hostUrl+\"/temp?fileName=$fileName&dir=win%2F$bit\";\r\n\t\t$Res=Download-File \"$remoteSoftwarePath\" \"$softwarePath\";\"$business$Res\";\r\n\t\tIf(!(Is-Success $Res)){Return}\r\n\t}\r\n\r\n\t$Suffix=(Get-ChildItem -Path $softwarePath).Extension.substring(1);\r\n\tIf('msi' -eq $Suffix){\r\n\t\t$os=Get-WmiObject -Class Win32_OperatingSystem | Select -ExpandProperty Caption\r\n\t\tIf($os -Like '*Windows 7*' -Or $os -Like '*Windows 8*'){\r\n\t\t\tInvoke-Expression \"& cmd /c `'msiexec.exe /i `\"$softwarePath`\"`' /qn ADVANCED_OPTIONS=1 CHANNEL=100\"\r\n\t\t}Else{\r\n\t\t\tInvoke-Expression \"Msiexec /i `\"$softwarePath`\" /norestart /qn\" -ErrorAction SilentlyContinue;\r\n\t\t\tIf(!$?){Return Print-Exception \"Msiexec /i `\"$softwarePath`\" /norestart /qn\"}\r\n\t\t\tStart-Sleep 3\r\n\t\t}\r\n\t}else{\r\n\t\t$Res=OperatorSoftwareBySWI $hostUrl $softwarePath;\"$business$Res\";\r\n\t\tIf(!(Is-Success $Res)){Return}\r\n\t}\r\n\tIf((Get-SoftwareInfoByNameVersion $softwareName $softwareVersion) -eq $null){Return \"BusinessException:Installation of the software has not been successful\"}\r\n\r\n\tIf($isRun){\r\n\t\tIf(![String]::isNullOrEmpty($serviceName)){\r\n\t\t\t$Res = Set-Serviced $serviceName 'Automatic' 'Running';\"$business$Res\";\r\n\t\t\tIf(!(Is-Success $Res)){Return}\r\n\t\t}\r\n\t\tIf(![String]::isNullOrEmpty($processName)){\r\n\t\t\t$Res = Set-Processd $processName $true $startFileDir;\"$business$Res\";\r\n\t\t\tIf(!(Is-Success $Res)){Return}\r\n\t\t}\r\n\t}\r\n\tReturn Ret-Success $business\r\n}",
  "callContent" : "White-Software ~hostUrl~ ~softwareName~ ~softwareVersion~ ~fileName64~ ~fileName32~ ~isRun~ ~processName~",
  "subNames" : ["Ret-Success", "Is-Success", "Print-Exception", "Download-File", "Get-SoftwareInfoByNameVersion", "Set-Serviced", "Set-Processd", "OperatorSoftwareBySWI"]
},{
  "name" : "Print-Exception",
  "desc" : "执行命令异常统一处理",
  "content" : "Function Print-Exception([String]$command){\r\n\tReturn \"execute Command [$command] Exception,The Exception is $($error[0])\"\r\n}",
  "callContent" : "",
  "subNames" : []
},{
  "name" : "Ret-Success",
  "desc" : "处理成功时,统一格式返回",
  "content" : "Function Ret-Success([String] $business){\r\n\tReturn \"$business%%SMP:success\"\r\n}",
  "callContent" : "",
  "subNames" : []
},{
  "name" : "Is-Success",
  "desc" : "判断子调度是否成功",
  "content" : "Function Is-Success($Ret){\r\n\tIf($Ret -ne $null -And ($Ret|Select -Last 1).EndsWith('%%SMP:success')){Return $True}\r\n\tReturn $False\r\n}",
  "callContent" : "",
  "subNames" : []
},{
  "name" : "Download-File",
  "desc" : "文件下载(软件安装包,工具文件等)",
  "content" : "Function Download-File($src,$des,$isReplace=$true){\r\n\tIf([String]::IsNullOrEmpty($src)){Return \"BusinessException:Source file does not exist\"}\r\n\tIf([String]::IsNullOrEmpty($des)){Return \"BusinessException:Destination address cannot be empty\"}\r\n\tIf(!$isReplace -And (Test-Path $des)){Return Ret-Success \"Download-File:No Need Operator\"}\r\n\tTry{\r\n\t\t$web=New-Object System.Net.WebClient;\r\n\t\t$web.Encoding=[System.Text.Encoding]::UTF8;\r\n                            $web.DownloadFile(\"$src\", \"$des\");\r\n\t\tIf(!(Test-Path $des) -or (Get-Content \"$des\" -totalcount 1) -eq $null){Return \"BusinessException:The downloaded file does not exist or the content is empty\"}\r\n\t}Catch{Return Print-Exception \"$web.DownloadFile($src,$des)\"}\t\r\n\tReturn Ret-Success \"Download-File\"\r\n}",
  "callContent" : "",
  "subNames" : ["Ret-Success", "Print-Exception"]
},{
  "name" : "Get-SoftwareInfoByNameVersion",
  "desc" : "根据软件名称(必输)和版本(可选)获取软件信息",
  "content" : "Function Get-SoftwareInfoByNameVersion([String] $name,[String] $version){\r\n\t$Key='Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall','SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall';\r\n\tIf([IntPtr]::Size -eq 8){$Key+='SOFTWARE\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall'}\r\n\tForeach($_ In $Key){\r\n\t  $Hive='LocalMachine';\r\n\t  If('Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall' -ceq $_){$Hive='CurrentUser'}\r\n\t  $RegHive=[Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($Hive,$env:COMPUTERNAME);\r\n\t  $RegKey=$RegHive.OpenSubKey($_);\r\n\t  If([string]::IsNullOrEmpty($RegKey)){Continue}\r\n\t  $arrs=$RegKey.GetSubKeyNames();\r\n\t  Foreach($_ In $arrs){\r\n\t\t$SubKey=$RegKey.OpenSubKey($_);\r\n\t\t$tmp=$subkey.GetValue('DisplayName');\r\n\t\tIf(![string]::IsNullOrEmpty($tmp)){\r\n\t\t\tIf($tmp.gettype().name -eq 'string' -and $tmp -like $name){\r\n\t\t\t\t$DisplayVersion=$subkey.GetValue('DisplayVersion');\r\n\t\t\t\tIf(![string]::IsNullOrEmpty($version) -and $version -notlike $DisplayVersion){Continue}\r\n\t\t\t\t$retVal=''|Select 'DisplayName','DisplayVersion','UninstallString','InstallLocation','RegPath','InstallDate','InstallSource';\r\n\t\t\t\t$retVal.DisplayName=$subkey.GetValue('DisplayName');\r\n\t\t\t\t$retVal.DisplayVersion=$DisplayVersion;\r\n\t\t\t\t$retVal.UninstallString=$subkey.GetValue('UninstallString');\r\n\t\t\t\t$retVal.InstallLocation=$subkey.GetValue('InstallLocation');\r\n\t\t\t\t$retVal.RegPath=$subkey.GetValue('RegPath');\r\n\t\t\t\t$retVal.InstallDate=$subkey.GetValue('InstallDate');\r\n\t\t\t\t$retVal.InstallSource=$subkey.GetValue('InstallSource');\r\n\t\t\t\tReturn $retVal;\r\n\t\t\t}\r\n\t\t}\r\n\t\t$SubKey.Close()\r\n\t  };\r\n\t  $RegHive.Close()\r\n\t};\r\n}",
  "callContent" : "Get-SoftwareInfoByNameVersion $name $version",
  "subNames" : []
},{
  "name" : "OperatorSoftwareBySWI",
  "desc" : "通过SWI安装或卸载软件",
  "content" : "Function OperatorSoftwareBySWI([String]$hostUrl,[String]$softwarePath){\r\n\t$business=\"[OperatorSoftwareBySWI:$softwarePath]=>>\"\r\n\tIf([String]::IsNullOrEmpty(\"$softwarePath\")){\r\n\t\tReturn \"uninstall script not exist\"\r\n\t}\r\n\tIf(!$softwarePath.EndsWith(\".exe\")){\r\n\t\tReturn \"uninstall script format error[$softwarePath]\"\r\n\t}\r\n\tIf($softwarePath.StartsWith('\"')){\r\n\t\t$softwarePath=$softwarePath.substring(1,$softwarePath.LastIndexOf('\"'))\r\n\t}\r\n\t$SWIDir=Join-Path $env:SystemDrive '\\Program Files\\Ruijie Networks\\softwarePackage';\r\n\tIf(!(Test-Path $SWIDir)){\r\n\t\tmkdir $SWIDir -Force|Out-Null;\r\n\t\tIf(!$?){Return Print-Exception \"${business}mkdir $SWIDir -Force|Out-Null\"}\r\n\t}\r\n\t$SWIFileName='SWIService.exe';\r\n\t$SWIPath=Join-Path $SWIDir $SWIFileName;\r\n\t$SWIServiceName='SWIserv';\r\n\t$SWI=Get-Service -Name \"${SWIServiceName}*\"\r\n\tIf (!(Test-Path \"$SWIPath\")){\r\n\t\t$remoteexePath=$hostUrl +'/'+ $SWIFileName;\t\r\n\t\t$Res=Download-File \"$remoteexePath\" \"$SWIPath\";\"$business$Res\";\r\n\t\tIf(!(Is-Success $Res)){Return}\r\n\t}\r\n\t\r\n\tIf($null -eq $SWI){\r\n\t\tTry{\r\n\t\t\tSet-Location $SWIDir; \r\n\t\t\t.\\SWIService.exe -install -ErrorAction Stop\r\n\t\t}Catch{\r\n\t\t\tReturn Print-Exception \"${business}.\\SWIService.exe -install -ErrorAction Stop\"\r\n\t\t}\r\n\t}else{\r\n\t\tIf($SWI.Status -eq 'Running'){\r\n\t\t\tStop-Service -Name $SWIServiceName -ErrorAction SilentlyContinue;\r\n\t\t\tIf(!$?){Return Print-Exception \"${business}Stop-Service -Name $SWIServiceName\"}\r\n\t\t}\r\n\t}\r\n\tTry{\r\n\t\t(Get-Service -Name $SWIServiceName).Start(\"{`\"exe`\":`\"$softwarePath`\",`\"arg`\":`\"/s`\"}\")\r\n\t}Catch{\r\n\t\tReturn Print-Exception \"${business}(Get-Service -Name $SWIServiceName).Start(\"+'\"{`\"exe`\":'+\"$softwarePath\"+',`\"arg`\":`\"/s`\"}\")'\r\n\t}\r\n\tReturn Ret-Success ${business}\r\n}",
  "callContent" : "OperatorSoftwareBySWI $hostUrl $softwarePath",
  "subNames" : ["Ret-Success", "Is-Success", "Print-Exception", "Download-File"]
},{
  "name" : "Set-Serviced",
  "desc" : "服务操作",
  "content" : "Function Set-Serviced($serviceName,$startType,$status){\r\n\t$business=\"[Set-Serviced $serviceName]=>>\"\r\n\t$service=Get-Service $serviceName -ErrorAction SilentlyContinue;\r\n\tIf(!$?){Return Print-Exception \"${business}Get-Service $serviceName\"}\r\n\tif($service.status -ne $status){\r\n\t\tSet-Service $serviceName -StartupType Automatic -Status $status -ErrorAction SilentlyContinue;\r\n\t\tIf(!$?){Print-Exception \"Set-Service $serviceName -Status $status\";}\r\n\t\tSleep 1\r\n\t}\r\n\t#StartupType:[Boot|System|Automatic|Manual|Disabled],Status:[Running|Stopped|Paused]\r\n\tif($service.StartupType -ne $startType){\r\n\t\tSet-Service $serviceName -StartupType $startType -ErrorAction SilentlyContinue;\r\n\t\tIf(!$?){Return Print-Exception \"${business}Set-Service $serviceName -StartupType $startType\"}\r\n\t}\t\r\n\tReturn Ret-Success $business\r\n}",
  "callContent" : "Set-Serviced $serviceName $startType $status",
  "subNames" : ["Ret-Success", "Print-Exception"]
},{
  "name" : "Set-Processd",
  "desc" : "进程操作",
  "content" : "Function Set-Processd($processName,$isRun,$startFile,$isClear){\r\n\t$business=\"[Set-Processd $processName]=>>\"\r\n\tIf([String]::isNullOrEmpty($processName)){\r\n\t\tReturn \"${business}BusinessException:processName can not empty\"\r\n\t}\r\n\t\r\n\t$pro=Get-Process $processName -ErrorAction SilentlyContinue;\r\n\tIf($isRun){\r\n\t\tIf($pro -ne $null){\r\n\t\t\tReturn '${business}No Need Operator%%SMP:success'\r\n\t\t}\r\n\t\tIf([String]::isNullOrEmpty($startFile)){\r\n\t\t\tReturn \"${business}BusinessException:To start a process, The process startFile cannot be empty\";\t\r\n\t\t}\r\n\t\t\r\n\t\tIf(!(Test-Path $startFile)){\r\n\t\t\tReturn \"${business}BusinessException:[$startFile] does not exist,cannot start process\"\r\n\t\t}\r\n\t\t\r\n\t\tStart-Process $startFile -ErrorAction SilentlyContinue;\r\n\t\tIf(!$?){Return Print-Exception \"${business}Start-Process $startFile\"}\r\n\t\t\r\n\t\tReturn Ret-Success $business\r\n\t}Else{\r\n\t\tIf($pro -eq $null){\r\n\t\t\tIf($isClear){\r\n\t\t\t\tIf([String]::isNullOrEmpty($startFile)){\r\n\t\t\t\t\tReturn \"${business}BusinessException:To clean up a process, The process startFile cannot be empty\";\t\r\n\t\t\t\t}\r\n\t\t\t\tRemove-Item -Force $startFile -ErrorAction SilentlyContinue;\r\n\t\t\t\tIf(!$?){Return Print-Exception \"${business}Remove-Item -Force $startFile\"}\r\n\t\t\t}\r\n\t\t\tReturn '${business}No Need Operator%%SMP:success'\r\n\t\t}\r\n\t\t\r\n\t\t$pro|Foreach{\r\n\t\t\tStop-Process $_.Id -Force -ErrorAction SilentlyContinue;\r\n\t\t\tIf(!$?){Print-Exception \"Stop-Process $_.Id -Force\"}\r\n\t\t}\r\n\t\tSleep 1;\r\n\t\t\r\n\t\t$pro=Get-Process $processName -ErrorAction SilentlyContinue;\t\r\n\t\tIf($pro -ne $null){\r\n\t\t\tReturn \"${business}BusinessException:Failed to terminate process\"\r\n\t\t}\r\n\t\t\r\n\t\tIf($isClear){\r\n\t\t\tIf([String]::isNullOrEmpty($startFile)){\r\n\t\t\t\tReturn \"${business}BusinessException:To start a process, The process startFile cannot be empty\";\t\r\n\t\t\t}\r\n\t\t\t\r\n\t\t\tIf(!(Test-Path $startFile)){\r\n\t\t\t\tReturn \"${business}BusinessException:[$startFile] does not exist,cannot start process\"\r\n\t\t\t}\r\n\t\t\t\r\n\t\t\tRemove-Item -Force $startFile -ErrorAction SilentlyContinue;\r\n\t\t\tIf(!$?){Return Print-Exception \"Remove-Item -Force $startFile\"}\r\n\t\t}\r\n\t\tReturn ${business}\r\n\t}\r\n}",
  "callContent" : "",
  "subNames" : ["Ret-Success", "Print-Exception"]
},{
  "name" : "Black-SoftwareArr",
  "desc" : "批量卸载黑名单软件",
  "params" : [{
      "name" : "~softwareList~",
      "defaultValue" : "$null",
      "type" : "Array"
    }],
  "content" : "Function Black-SoftwareArr($blackList){\r\n\t$suc=0;\r\n\t$res=1|Select success,sum,logs;\r\n\t$blackList|ConvertFrom-Csv|Foreach{\r\n\t\t$ret=Black-Software $_.softwareName $_.softwareVersion $_.isAuto $_.processName $_.serviceName;$res.logs+=\"<<$_ :\"+$ret+'>>';\r\n\t\tIf(Is-Success $ret){$suc+=1}\r\n\t}\r\n\t$res.success=$suc;\r\n\t$res.sum=$blackList.length-1;\r\n\t$tt=ConvertTo-Csv $res|Select -Skip 1\r\n\tReturn $tt\r\n}",
  "callContent" : "Black-SoftwareArr @(\"softwareName,softwareVersion,isAuto,processName,serviceName\", ~softwareList~);",
  "analyzingContent" : "package com.ruijie.authentication.session.program.domain.program;\r\ndialect  \"java\"\r\nimport com.ruijie.authentication.session.program.domain.program.PsScriptTemplateAnalyzingProcedureFact\r\nimport com.ruijie.authentication.authnode.domain.node.compliance.ComplianceDetectingResultState\r\nimport com.ruijie.common.utils.CsvUtil\r\nimport java.util.List\r\nrule \"classify\"\r\nwhen\r\n    fact:PsScriptTemplateAnalyzingProcedureFact()\r\nthen\r\n    String response = fact.getScriptResponse().getResponse();\r\n    fact.setResultState(ComplianceDetectingResultState.COMPLIANCE_FAIL);\r\n    List<PsBatchResult> csvData = CsvUtil.getCsvData(response, PsBatchResult.class);\r\n    if(!csvData.isEmpty()){\r\n        PsBatchResult psRetResult = csvData.get(0);\r\n        if(psRetResult.getSuccess()==psRetResult.getSum()){\r\n            fact.setResultState(ComplianceDetectingResultState.COMPLIANCE_SUFFICE);\r\n        }\r\n    }\r\n    fact.setResponse(response);\r\nend",
  "subNames" : ["Black-Software", "Ret-Success", "Is-Success", "Print-Exception", "Set-Serviced", "Set-Processd", "Get-SoftwareInfoByNameVersion", "OperatorSoftwareBySWI"]
},{
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
  "content" : "Function Black-Software($softwareName,$softwareVersion,$isAuto,$processName,$serviceName){\r\n\t$business=\"[uninstall $softwareName]=>>\";\r\n\tIf([String]::isNullOrEmpty($softwareName)){Return \"BusinessException:softwareName can not empty\"}\r\n\t\r\n\t$retVal=Get-SoftwareInfoByNameVersion $softwareName $softwareVersion;\r\n\tIf($retVal -eq $null){Return Ret-Success \"${business}the $softwareName is Already exist\"}\r\n\r\n\tIf([String]::isNullOrEmpty($retVal.UninstallString)){Return \"BusinessException:Uninstall command does not exist, unable to uninstall\"}\r\n\r\n\tIf(![String]::isNullOrEmpty($serviceName)){(Set-Serviced $serviceName 'Disabled' 'Stopped')|Foreach{\"$business$_\"}}\r\n\r\n\tIf(![String]::isNullOrEmpty($processName)){(Set-Processd $processName $False $startFileDir $True)|Foreach{\"$business$_\"}}\r\n\r\n\t$UninstallString=$retVal.UninstallString.Trim().ToLower();\r\n\t$iexe='msiexec.exe';\r\n\tIf($UninstallString.StartsWith($iexe)){\r\n\t\t$msicode=$UninstallString.substring($UninstallString.indexof('{'));\r\n\t\tIf($isAuto){$pra=\"/quiet\"}Else{$pra=''}\r\n\t\tInvoke-Expression \"$iexe /x `\"$msicode`\" /norestart $pra\" -ErrorAction SilentlyContinue\r\n\t\tIf(!$?){Return Print-Exception 'Invoke-Expression \"'+\"$iexe\"+ ' /x `\"'+\"$msicode\"+'`\" /norestart /quiet\"'}\r\n\t\tSleep 1\r\n\t}Else{OperatorSoftwareBySWI $hostUrl $UninstallString}\r\n\r\n\tIf((Get-SoftwareInfoByNameVersion $softwareName $version) -ne $null){Return \"BusinessException:Uninstallation has not been successful\"}\r\n\tReturn Ret-Success $business\r\n}",
  "callContent" : "",
  "subNames" : ["Ret-Success", "Is-Success", "Print-Exception", "Set-Serviced", "Set-Processd", "Get-SoftwareInfoByNameVersion", "OperatorSoftwareBySWI"]
},{
  "name" : "ps00001-openFireWall",
  "desc" : "开启防火墙",
  "callContent" : "function getFireWallState { $content = netsh advfirewall show allprofile;  [regex]$firewallState = \"(?:State|\\u72B6\\u6001)\\s*(\\S*)\"; $matches = $firewallState.Matches($content); [regex]$firewallResult = \"(OFF|\\u5173\\u95ed)\"; foreach ($match in $matches) { if ($firewallResult.Matches($match.Groups[1].Value).Success){ return $false; } } return $true; };  if (getFireWallState){ Write-Host \"%%SMP:detecting-suffice\"; }else { netsh advfirewall set allprofile state on; if (getFireWallState) { Write-Host \"%%SMP:executing-suffice\"; } else { Write-Host \"%%SMP:executing-fail\"; } }",
  "analyzingContent" : "package pstemplates.openfirewall;\r\ndialect  \"mvel\"\r\n\r\nimport com.ruijie.authentication.session.program.domain.program.PsScriptTemplateAnalyzingProcedureFact;\r\nimport com.ruijie.authentication.authnode.domain.node.LabelValue;\r\nimport com.ruijie.authentication.authnode.domain.node.compliance.ComplianceDetectingResultState;\r\nimport com.ruijie.authentication.authnode.domain.label.LabelConstant;\r\n\r\nrule \"analyzingScript\"\r\n    when\r\n        $fact: PsScriptTemplateAnalyzingProcedureFact($node: node, $scriptResponse: scriptResponse, $labels: updateLabels)\r\n    then\r\n        if ($scriptResponse.isError() || $scriptResponse.isTimeout()){\r\n            $fact.setResultState(ComplianceDetectingResultState.EXCEPTION_SUFFICE);\r\n            $fact.setOperateRecord(\"执行异常或执行操作，默认合规\");\r\n        } else {\r\n           String response = $scriptResponse.getResponse();\r\n           String result = response.substring(response.indexOf(\"%%SMP:\") + 6);\r\n           if (\"detecting-suffice\".equals(result) || \"executing-suffice\".equals(result)){\r\n                $labels.put(LabelConstant.FIRE_WALL_ALL_ON, LabelValue.builder()\r\n                                        .value(true)\r\n                                        .build());\r\n                $fact.setResultState(ComplianceDetectingResultState.COMPLIANCE_SUFFICE);\r\n                $fact.setOperateRecord(\"防火墙已开启！\");\r\n           }else if(\"executing-fail\".equals(result)){\r\n                $labels.put(LabelConstant.FIRE_WALL_ALL_ON, LabelValue.builder()\r\n                                        .value(false)\r\n                                        .build());\r\n                $fact.setResultState(ComplianceDetectingResultState.COMPLIANCE_FAIL);\r\n                $fact.setOperateRecord(\"防火墙开启失败！\");\r\n           } else {\r\n                $labels.put(LabelConstant.FIRE_WALL_ALL_ON, LabelValue.builder()\r\n                                                       .value(true)\r\n                                                       .build());\r\n                $fact.setResultState(ComplianceDetectingResultState.COMPLIANCE_SUFFICE);\r\n                $fact.setOperateRecord(\"内部异常，默认合规！\");\r\n           }\r\n        }\r\nend\r\n",
  "_version_" : "0",
  "createTime" : ISODate("2020-02-03T08:15:59.227Z"),
  "lastModifiedTime" : ISODate("2020-02-03T08:15:59.227Z"),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
},{
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
  "analyzingContent" : "package com.ruijie.authentication.session.program.domain.program;\r\ndialect  \"java\"\r\nimport com.ruijie.authentication.session.program.domain.program.PsScriptTemplateAnalyzingProcedureFact\r\nimport com.ruijie.authentication.authnode.domain.node.compliance.ComplianceDetectingResultState\r\nrule \"classify\"\r\nwhen\r\n    fact:PsScriptTemplateAnalyzingProcedureFact()\r\nthen\r\n    if(!fact.getScriptResponse().getResponse().endsWith(\"%%SMP:success\")){\r\n        fact.setResultState(ComplianceDetectingResultState.COMPLIANCE_FAIL);\r\n        fact.setResponse(fact.getScriptResponse().getResponse());\r\n    }\r\nend",
  "content" : "Function System-Patch($hostUrl,$fileName,$osArchitecture,$adapterProducts,$kbNum){\r\n    #获取终端操作系统版本和架构\r\n    $product = (Get-WmiObject -Class Win32_OperatingSystem).Caption\r\n    $matched = $false\r\n    foreach ($ad in $adapterProducts){\r\n        if($product -like \"*\"+$ad+\"*\"){\r\n            $matched = $true\r\n            break\r\n        }\r\n    }\r\n    if(!$matched){\r\n        return \"product not matched\"\r\n    }\r\n\r\n    if(!((Get-WmiObject -Class Win32_OperatingSystem).osarchitecture -like (\"\"+$osArchitecture+\"-bit\"))){\r\n        return \"osarchitecture not matched\"\r\n    }\r\n\r\n    #判断补丁是否已安装\r\n    if (get-hotfix -id (\"KB\"+$kbNum) -ErrorAction SilentlyContinue){\r\n        return \"This patch is aready installed successfully.\"\r\n    }\r\n\r\n\r\n    #下载补丁文件到终端\r\n    $web=New-Object System.Net.WebClient;\r\n    Invoke-Expression $web.DownloadString(\"ftp://192.168.54.108/PrintException.ps1\");\r\n\r\n    If([String]::isNullOrEmpty($hostUrl)){\r\n\t    Return \"BusinessException:hostUrl can not empty\"\r\n    }\r\n\r\n    $downloadPath = Join-Path $env:SystemDrive '/Program Files/Ruijie Networks/systemPatches/';\r\n    If(!(Test-Path $downloadPath)){New-Item $downloadPath -ItemType Directory -Force|Out-Null}\r\n    Set-Location $downloadPath\r\n\r\n    If([String]::isNullOrEmpty($fileName)){\r\n\t    Return \"BusinessException:patch file name can not empty\"\r\n    }\r\n\r\n    $softwarePath = Join-Path $downloadPath $fileName;\r\n    If(!(Test-Path \"$softwarePath\") -or (Get-Item \"$softwarePath\").length -eq 0) {\r\n\t    $remoteSoftwarePath=$hostUrl+\"$fileName\";\r\n\t    try{\r\n\t\t    $web.DownloadFile(\"$remoteSoftwarePath\", \"$softwarePath\")\r\n\t\t    If((Get-Item \"$softwarePath\").length -eq 0){\r\n\t\t\t    Return \"BusinessException:no installation package available\"\r\n\t\t    }\r\n\t    }Catch{\r\n\t\t    Return PrintException (\"$web.DownloadFile(`\"$remoteSoftwarePath`\",`\"$softwarePath`\")\")\r\n\t    }\r\n    }\r\n\r\n    #根据补丁后缀名安装补丁\r\n    $Suffix=(Get-ChildItem -Path $softwarePath).Extension.substring(1);\r\n    If('msu' -eq $Suffix){\r\n        $expandFolder = $downloadPath + $fileName.Split(\"_\")[0]\r\n        mkdir $expandFolder\r\n        expand -F:* $softwarePath $expandFolder\r\n        $cabFullName = Get-ChildItem $expandFolder | where {$_.FullName -like \"*cab\" -and $_.FullName -notlike \"*WSUSSCAN.cab\"} | foreach {$_.FullName}\r\n        $ret=dism.exe /online /add-package /packagepath:\"$cabFullName\" /quiet /norestart\r\n        Remove-Item $expandFolder\"/*\"\r\n        if($ret -like \"*0x800f081e1*\"){\r\n            return \"The specified package is not applicable to this image\"\r\n        }\r\n\t    If(!$?){Return PrintException \"dism.exe /online /add-package /packagepath:`\"$cabFullName`\" /quiet /norestart\"}\r\n    }elseif('cab' -eq $Suffix){\r\n        $ret=dism.exe /online /add-package /packagepath:\"$softwarePath\" /quiet /norestart\r\n        if($ret -like \"*0x800f081e1*\"){\r\n            return \"The specified package is not applicable to this image\"\r\n        }\r\n        If(!$?){Return PrintException \"dism.exe /online /add-package /packagepath:`\"$softwarePath`\" /quiet /norestart\"}\r\n    }elseif('exe' -eq $Suffix){\r\n        start \"$softwarePath\" -Wait -ArgumentList \"/quiet /norestart\"\r\n\t    If(!$?){Return PrintException \"start `\"$softwarePath`\" -Wait -ArgumentList `\"/quiet /norestart`\"\"}\r\n    }\r\n\r\n    #判断补丁是否安装成功\r\n    if (!(get-hotfix -id (\"KB\"+$kbNum) -ErrorAction SilentlyContinue)){\r\n        return \"This patch fail to install.\"\r\n    }\r\n\r\n    Return \"%%SMP:success\"\r\n}",
  "callContent" : "System-Patch ~hostUrl~ ~fileName~ ~osArchitecture~ ~adapterProducts~ ~kbNum~",
  "subNames" : ["Print-Exception"]
}
])