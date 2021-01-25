/* 1 */
{
  "_id" : ObjectId("5e1ebbb930bac317c1caed97"),
  "name" : "Get-InstalledSoftware",
  "desc" : "收集终端软件信息",
  "content" : "Function Get-InstalledSoftware{\r\n\t$Key='Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall','SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall';\r\n\tIf([IntPtr]::Size -eq 8){\r\n\t   $Key+='SOFTWARE\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall'\r\n\t}\r\n\t$Value='DisplayName','DisplayVersion','UninstallString','InstallLocation','RegPath','EstimatedSize','InstallDate','InstallSource','Language','ModifyPath','Publisher','icon';\r\n\tForeach($_ in $Key){\r\n\t  $Hive='LocalMachine';\r\n\t  If('Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall' -ceq $_){$Hive='CurrentUser'}\r\n\t  $RegHive=[Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($Hive,$env:COMPUTERNAME);\r\n\t  $RegKey=$RegHive.OpenSubKey($_);\r\n\t  If([string]::IsNullOrEmpty($RegKey)){Continue}\r\n\t  $RegKey.GetSubKeyNames()|ForEach{\r\n\t\t$SubKey=$RegKey.OpenSubKey($_);\r\n\t\t$retVal=1|Select-Object -Property $Value;\r\n\t\tForEach($_ in $Value){\r\n\t\t\t$tmp=$subkey.GetValue($_);\r\n\t\t\tIf(![string]::IsNullOrEmpty($tmp)){\r\n\t\t\t\tIf($tmp.gettype().name -eq 'string'){\r\n\t\t\t\t\t$retVal.$_=($tmp -replace [Regex]::UnEscape('\\u0000'), '').Replace('\"','').Replace('\\','/')\r\n\t\t\t\t}Elseif($tmp.gettype().name -eq 'int32'){\r\n\t\t\t\t\t$retVal.$_=$tmp\r\n\t\t\t\t}\r\n\t\t\t}\r\n\t\t};\r\n\t\tIf(![string]::IsNullOrEmpty($SubKey.GetValue('DisplayName'))){\r\n\t\t\t$tmp=$SubKey.Name;\r\n\t\t\tIf(![string]::IsNullOrEmpty($tmp)){\r\n\t\t\t\t$retVal.RegPath=($tmp -replace [Regex]::UnEscape('\\u0000'), '').Replace('\"','').Replace('\\','/')\r\n\t\t\t}\r\n\t\t\t$retVal\r\n\t\t}\r\n\t\t$SubKey.Close()\r\n\t  };\r\n\t  $RegHive.Close()\r\n\t}\r\n}",
  "callContent" : "Get-InstalledSoftware|ConvertTo-Csv|Select -Skip 1",
  "subNames" : []
}

/* 2 */
{
  "_id" : ObjectId("5e1ebbb930bac317c1caed98"),
  "name" : "White-Software",
  "desc" : "软件白名单脚本模板",
  "params" : [{
      "name" : "~hostUrl~",
      "defaultValue" : "$null"
    }, {
      "name" : "~softwareName~",
      "defaultValue" : "$null"
    }, {
      "name" : "~softwareVersion~",
      "defaultValue" : "$null"
    }, {
      "name" : "~fileName64~",
      "defaultValue" : "$null"
    }, {
      "name" : "~fileName32~",
      "defaultValue" : "$null"
    }, {
      "name" : "~isRun~",
      "defaultValue" : "$true"
    }, {
      "name" : "~processName~",
      "defaultValue" : "$null"
    }],
  "analyzingContent" : "package com.ruijie.authentication.session.program.domain.program;\r\ndialect  \"java\"\r\nimport com.ruijie.authentication.session.program.domain.program.PsScriptTemplateAnalyzingProcedureFact\r\nimport com.ruijie.authentication.authnode.domain.node.compliance.ComplianceDetectingResultState\r\nrule \"classify\"\r\nwhen\r\n    fact:PsScriptTemplateAnalyzingProcedureFact(scriptResponse.getResponse not matches \"*%%SMP:success\")\r\nthen\r\n    fact.setResultState(ComplianceDetectingResultState.COMPLIANCE_FAIL);\r\n    fact.setResponse(fact.getScriptResponse().getResponse());\r\nend",
  "content" : "Function White-Software($hostUrl,$softwareName,$fileName64,$fileName32,$isRun,$processName,$serviceName){\r\n\t$business=\"[Install $softwareName]=>>\";\r\n\tIf([String]::isNullOrEmpty($softwareName)){Return \"BusinessException:softwareName can not empty\"}\r\n\tIf((Get-SoftwareInfoByNameVersion $softwareName $version) -ne $null){\r\n\t\tIf(!$isRun){Return Ret-Success $business}\r\n\t\tIf([String]::isNullOrEmpty($serviceName) -and [String]::isNullOrEmpty($processName)){\r\n\t\t\tReturn \"BusinessException:The software needs to be opened. The process name and service name cannot both be empty\"\r\n\t\t}\r\n\t\tIf(![String]::isNullOrEmpty($serviceName)){\r\n\t\t\t$Res = Set-Serviced $serviceName 'Automatic' 'Running';\"$business$Res\";\r\n\t\t\tIf(Is-Success $Res){Return}\r\n\t\t}\r\n\t\tIf(![String]::isNullOrEmpty($processName)){\r\n\t\t\t$Res = Set-Processd $processName $true $null;\"$business$Res\";\r\n\t\t\tIf(Is-Success $Res){Return}\r\n\t\t}\r\n\t}\r\n\r\n\tIf([String]::isNullOrEmpty($hostUrl)){Return \"BusinessException:hostUrl can not empty\"}\r\n\tIf([String]::isNullOrEmpty($fileName64) -and [String]::isNullOrEmpty($fileName32)){Return \"BusinessException:install package can not empty\"}\r\n\r\n\t$downloadPath = Join-Path $env:SystemDrive '/Program Files/Ruijie Networks/softwarePackage/';\r\n\tIf(!(Test-Path $downloadPath)){mkdir $downloadPath -Force|Out-Null}\r\n\r\n\tIf([IntPtr]::Size -eq 8 -and ![String]::isNullOrEmpty($fileName64)){\r\n\t\t$bit='bit64';\r\n\t\t$fileName=$fileName64;\r\n\t}Else{\r\n\t\t$bit='bit32';\r\n\t\t$fileName=$fileName32\r\n\t}\r\n\r\n\t$softwarePath = Join-Path $downloadPath $fileName;\r\n\tIf(!(Test-Path \"$softwarePath\") -or (Get-Content \"$softwarePath\" -TotalCount 1) -eq $null){\r\n\t\t$remoteSoftwarePath=$hostUrl+\"/temp?fileName=$fileName&dir=$bit\";\r\n\t\t$Res=Download-File \"$remoteSoftwarePath\" \"$softwarePath\";\"$business$Res\";\r\n\t\tIf(!(Is-Success $Res)){Return}\r\n\t}\r\n\r\n\t$Suffix=(Get-ChildItem -Path $softwarePath).Extension.substring(1);\r\n\tIf('msi' -eq $Suffix){\r\n\t\t$os=Get-WmiObject -Class Win32_OperatingSystem | Select -ExpandProperty Caption\r\n\t\tIf($os -Like '*Windows 7*' -Or $os -Like '*Windows 8*'){\r\n\t\t\tInvoke-Expression \"& cmd /c `'msiexec.exe /i `\"$softwarePath`\"`' /qn ADVANCED_OPTIONS=1 CHANNEL=100\"\r\n\t\t}Else{\r\n\t\t\tInvoke-Expression \"Msiexec /i `\"$softwarePath`\" /norestart /qn\" -ErrorAction SilentlyContinue;\r\n\t\t\tIf(!$?){Return Print-Exception \"Msiexec /i `\"$softwarePath`\" /norestart /qn\"}\r\n\t\t\tStart-Sleep 3\r\n\t\t}\r\n\t}else{\r\n\t\t$Res=OperatorSoftwareBySWI $hostUrl $softwarePath;\"$business$Res\";\r\n\t\tIf(!(Is-Success $Res)){Return}\r\n\t}\r\n\tIf((Get-SoftwareInfoByNameVersion $softwareName $version) -eq $null){Return \"BusinessException:Installation of the software has not been successful\"}\r\n\r\n\tIf($isRun){\r\n\t\tIf(![String]::isNullOrEmpty($serviceName)){\r\n\t\t\t$Res = Set-Serviced $serviceName 'Automatic' 'Running';\"$business$Res\";\r\n\t\t\tIf(!(Is-Success $Res)){Return}\r\n\t\t}\r\n\t\tIf(![String]::isNullOrEmpty($processName)){\r\n\t\t\t$Res = Set-Processd $processName $true $startFileDir;\"$business$Res\";\r\n\t\t\tIf(!(Is-Success $Res)){Return}\r\n\t\t}\r\n\t}\r\n\tReturn Ret-Success $business\r\n}",
  "callContent" : "White-Software ~hostUrl~ ~softwareName~ ~fileName64~ ~fileName32~ ~isRun~ ~processName~",
  "subNames" : ["Ret-Success", "Is-Success", "Print-Exception", "Download-File", "Get-SoftwareInfoByNameVersion", "Set-Serviced", "Set-Processd", "OperatorSoftwareBySWI"]
}

/* 3 */
{
  "_id" : ObjectId("5e1ebbb930bac317c1caed99"),
  "name" : "Print-Exception",
  "desc" : "执行命令异常统一处理",
  "content" : "Function Print-Exception([String]$command){\r\n\tReturn \"execute Command [$command] Exception,The Exception is $($error[0])\"\r\n}",
  "callContent" : "",
  "subNames" : []
}

/* 4 */
{
  "_id" : ObjectId("5e1ebbb930bac317c1caed9a"),
  "name" : "Ret-Success",
  "desc" : "处理成功时,统一格式返回",
  "content" : "Function Ret-Success([String] $business){\r\n\tReturn \"$business%%SMP:success\"\r\n}",
  "callContent" : "",
  "subNames" : []
}

/* 5 */
{
  "_id" : ObjectId("5e1ebbb930bac317c1caed9b"),
  "name" : "Is-Success",
  "desc" : "判断子调度是否成功",
  "content" : "Function Is-Success($Ret){\r\n\tIf($Ret -ne $null -And ($Ret|Select -Last 1).EndsWith('%%SMP:success')){Return $True}\r\n\tReturn $False\r\n}",
  "callContent" : "",
  "subNames" : []
}

/* 6 */
{
  "_id" : ObjectId("5e1ebbb930bac317c1caed9c"),
  "name" : "Download-File",
  "desc" : "文件下载(软件安装包,工具文件等)",
  "content" : "Function Download-File($src,$des,$isReplace=$true){\r\n\tIf([String]::IsNullOrEmpty($src)){Return \"BusinessException:Source file does not exist\"}\r\n\tIf([String]::IsNullOrEmpty($des)){Return \"BusinessException:Destination address cannot be empty\"}\r\n\tIf(!$isReplace -And (Test-Path $des)){Return Ret-Success \"Download-File:No Need Operator\"}\r\n\tTry{\r\n\t\t$web=New-Object System.Net.WebClient;\r\n\t\t$web.Encoding=[System.Text.Encoding]::UTF8;\r\n                            $web.DownloadFile($src, $des);\r\n\t\tIf(!(Test-Path $des) -or (Get-Content \"$des\" -totalcount 1) -eq $null){Return \"BusinessException:The downloaded file does not exist or the content is empty\"}\r\n\t}Catch{Return Print-Exception \"$web.DownloadFile($src,$des)\"}\t\r\n\tReturn Ret-Success \"Download-File\"\r\n}",
  "callContent" : "",
  "subNames" : ["Ret-Success", "Print-Exception"]
}

/* 7 */
{
  "_id" : ObjectId("5e1ebbb930bac317c1caed9d"),
  "name" : "Get-SoftwareInfoByNameVersion",
  "desc" : "根据软件名称(必输)和版本(可选)获取软件信息",
  "content" : "Function Get-SoftwareInfoByNameVersion([String] $name,[String] $version){\r\n\t$Key='Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall','SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall';\r\n\tIf([IntPtr]::Size -eq 8){$Key+='SOFTWARE\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall'}\r\n\tForeach($_ In $Key){\r\n\t  $Hive='LocalMachine';\r\n\t  If('Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall' -ceq $_){$Hive='CurrentUser'}\r\n\t  $RegHive=[Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($Hive,$env:COMPUTERNAME);\r\n\t  $RegKey=$RegHive.OpenSubKey($_);\r\n\t  If([string]::IsNullOrEmpty($RegKey)){Continue}\r\n\t  $arrs=$RegKey.GetSubKeyNames();\r\n\t  Foreach($_ In $arrs){\r\n\t\t$SubKey=$RegKey.OpenSubKey($_);\r\n\t\t$tmp=$subkey.GetValue('DisplayName');\r\n\t\tIf(![string]::IsNullOrEmpty($tmp)){\r\n\t\t\tIf($tmp.gettype().name -eq 'string' -and $tmp -like $name){\r\n\t\t\t\t$DisplayVersion=$subkey.GetValue('DisplayVersion');\r\n\t\t\t\tIf(![string]::IsNullOrEmpty($version) -and $version -notlike $DisplayVersion){Continue}\r\n\t\t\t\t$retVal=''|Select 'DisplayName','DisplayVersion','UninstallString','InstallLocation','RegPath','InstallDate','InstallSource';\r\n\t\t\t\t$retVal.DisplayName=$subkey.GetValue('DisplayName');\r\n\t\t\t\t$retVal.DisplayVersion=$DisplayVersion;\r\n\t\t\t\t$retVal.UninstallString=$subkey.GetValue('UninstallString');\r\n\t\t\t\t$retVal.InstallLocation=$subkey.GetValue('InstallLocation');\r\n\t\t\t\t$retVal.RegPath=$subkey.GetValue('RegPath');\r\n\t\t\t\t$retVal.InstallDate=$subkey.GetValue('InstallDate');\r\n\t\t\t\t$retVal.InstallSource=$subkey.GetValue('InstallSource');\r\n\t\t\t\tReturn $retVal;\r\n\t\t\t}\r\n\t\t}\r\n\t\t$SubKey.Close()\r\n\t  };\r\n\t  $RegHive.Close()\r\n\t};\r\n}",
  "callContent" : "Get-SoftwareInfoByNameVersion $name $version",
  "subNames" : []
}

/* 8 */
{
  "_id" : ObjectId("5e1ebbb930bac317c1caed9e"),
  "name" : "OperatorSoftwareBySWI",
  "desc" : "通过SWI安装或卸载软件",
  "content" : "Function OperatorSoftwareBySWI([String]$hostUrl,[String]$softwarePath){\r\n\t$business=\"[OperatorSoftwareBySWI:$softwarePath]=>>\"\r\n\t$SWIDir=Join-Path $env:SystemDrive '\\Program Files\\Ruijie Networks\\softwarePackage';\r\n\tIf(!(Test-Path $SWIDir)){\r\n\t\tmkdir $SWIDir -Force|Out-Null;\r\n\t\tIf(!$?){Return Print-Exception \"${business}mkdir $SWIDir -Force|Out-Null\"}\r\n\t}\r\n\t$SWIFileName='SWIService.exe';\r\n\t$SWIPath=Join-Path $SWIDir $SWIFileName;\r\n\t$SWIServiceName='SWIserv';\r\n\tIf (!(Test-Path \"$SWIPath\")){\r\n\t\tIf($null -ne (Get-Service | Where {$_.Name -eq $SWIServiceName})){\r\n\t\t\tStop-Service -Name $SWIServiceName;\r\n\t\t\t(Get-WmiObject -Class win32_service | Where{$_.Name -eq $SWIServiceName}).Delete()|Out-Null\r\n\t\t}\r\n\t\t$remoteexePath=$hostUrl +'/'+ $SWIFileName;\t\r\n\t\t$Res=Download-File \"$remoteexePath\" \"$SWIPath\";\"$business$Res\";\r\n\t\tIf(!(Is-Success $Res)){Return}\r\n\t}\r\n\tTry{\r\n\t\tSet-Location $SWIDir; \r\n\t\t.\\SWIService.exe -install -ErrorAction Stop\r\n\t}Catch{\r\n\t\tReturn Print-Exception \"${business}.\\SWIService.exe -install -ErrorAction Stop\"\r\n\t}\r\n\tIf((Get-Service -Name $SWIServiceName).Status -eq 'Running'){\r\n\t\tStop-Service -Name $SWIServiceName -ErrorAction SilentlyContinue;\r\n\t\tIf(!$?){Return Print-Exception \"${business}Stop-Service -Name $SWIServiceName\"}\r\n\t}\r\n\t\r\n\tIf($softwarePath.StartsWith('\"')){\r\n\t\t$softwarePath=$softwarePath.substring(1,$softwarePath.LastIndexOf('\"'))\r\n\t}\t\r\n\tTry{\r\n\t\t(Get-Service -Name $SWIServiceName).Start(\"{`\"exe`\":`\"$softwarePath`\",`\"arg`\":`\"/s`\"}\")\r\n\t}Catch{\r\n\t\tReturn Print-Exception \"${business}(Get-Service -Name $SWIServiceName).Start(\"+'\"{`\"exe`\":'+\"$softwarePath\"+',`\"arg`\":`\"/s`\"}\")'\r\n\t}\r\n\tReturn Ret-Success ${business}\r\n}",
  "callContent" : "OperatorSoftwareBySWI $hostUrl $softwarePath",
  "subNames" : ["Ret-Success", "Is-Success", "Print-Exception", "Download-File"]
}

/* 9 */
{
  "_id" : ObjectId("5e1ebbb930bac317c1caed9f"),
  "name" : "Set-Serviced",
  "desc" : "服务操作",
  "content" : "Function Set-Serviced($serviceName,$startType,$status){\r\n\t$business=\"[Set-Serviced $serviceName]=>>\"\r\n\t$service=Get-Service $serviceName -ErrorAction SilentlyContinue;\r\n\tIf(!$?){Return Print-Exception \"${business}Get-Service $serviceName\"}\r\n\tif($service.status -ne $status){\r\n\t\tSet-Service $serviceName -StartupType Automatic -Status $status -ErrorAction SilentlyContinue;\r\n\t\tIf(!$?){Print-Exception \"Set-Service $serviceName -Status $status\";}\r\n\t\tSleep 1\r\n\t}\r\n\t#StartupType:[Boot|System|Automatic|Manual|Disabled],Status:[Running|Stopped|Paused]\r\n\tif($service.StartupType -ne $startType){\r\n\t\tSet-Service $serviceName -StartupType $startType -ErrorAction SilentlyContinue;\r\n\t\tIf(!$?){Return Print-Exception \"${business}Set-Service $serviceName -StartupType $startType\"}\r\n\t}\t\r\n\tReturn Ret-Success $business\r\n}",
  "callContent" : "Set-Serviced $serviceName $startType $status",
  "subNames" : ["Ret-Success", "Print-Exception"]
}

/* 10 */
{
  "_id" : ObjectId("5e1ebbb930bac317c1caeda0"),
  "name" : "Set-Processd",
  "desc" : "进程操作",
  "content" : "Function Set-Processd($processName,$isRun,$startFile,$isClear){\r\n\t$business=\"[Set-Processd $processName]=>>\"\r\n\tIf([String]::isNullOrEmpty($processName)){\r\n\t\tReturn \"${business}BusinessException:processName can not empty\"\r\n\t}\r\n\t\r\n\t$pro=Get-Process $processName -ErrorAction SilentlyContinue;\r\n\tIf($isRun){\r\n\t\tIf($pro -ne $null){\r\n\t\t\tReturn '${business}No Need Operator%%SMP:success'\r\n\t\t}\r\n\t\tIf([String]::isNullOrEmpty($startFile)){\r\n\t\t\tReturn \"${business}BusinessException:To start a process, The process startFile cannot be empty\";\t\r\n\t\t}\r\n\t\t\r\n\t\tIf(!(Test-Path $startFile)){\r\n\t\t\tReturn \"${business}BusinessException:[$startFile] does not exist,cannot start process\"\r\n\t\t}\r\n\t\t\r\n\t\tStart-Process $startFile -ErrorAction SilentlyContinue;\r\n\t\tIf(!$?){Return Print-Exception \"${business}Start-Process $startFile\"}\r\n\t\t\r\n\t\tReturn Ret-Success $business\r\n\t}Else{\r\n\t\tIf($pro -eq $null){\r\n\t\t\tIf($isClear){\r\n\t\t\t\tIf([String]::isNullOrEmpty($startFile)){\r\n\t\t\t\t\tReturn \"${business}BusinessException:To clean up a process, The process startFile cannot be empty\";\t\r\n\t\t\t\t}\r\n\t\t\t\tRemove-Item -Force $startFile -ErrorAction SilentlyContinue;\r\n\t\t\t\tIf(!$?){Return Print-Exception \"${business}Remove-Item -Force $startFile\"}\r\n\t\t\t}\r\n\t\t\tReturn '${business}No Need Operator%%SMP:success'\r\n\t\t}\r\n\t\t\r\n\t\t$pro|Foreach{\r\n\t\t\tStop-Process $_.Id -Force -ErrorAction SilentlyContinue;\r\n\t\t\tIf(!$?){Print-Exception \"Stop-Process $_.Id -Force\"}\r\n\t\t}\r\n\t\tSleep 1;\r\n\t\t\r\n\t\t$pro=Get-Process $processName -ErrorAction SilentlyContinue;\t\r\n\t\tIf($pro -ne $null){\r\n\t\t\tReturn \"${business}BusinessException:Failed to terminate process\"\r\n\t\t}\r\n\t\t\r\n\t\tIf($isClear){\r\n\t\t\tIf([String]::isNullOrEmpty($startFile)){\r\n\t\t\t\tReturn \"${business}BusinessException:To start a process, The process startFile cannot be empty\";\t\r\n\t\t\t}\r\n\t\t\t\r\n\t\t\tIf(!(Test-Path $startFile)){\r\n\t\t\t\tReturn \"${business}BusinessException:[$startFile] does not exist,cannot start process\"\r\n\t\t\t}\r\n\t\t\t\r\n\t\t\tRemove-Item -Force $startFile -ErrorAction SilentlyContinue;\r\n\t\t\tIf(!$?){Return Print-Exception \"Remove-Item -Force $startFile\"}\r\n\t\t}\r\n\t\tReturn ${business}\r\n\t}\r\n}",
  "callContent" : "",
  "subNames" : ["Ret-Success", "Print-Exception"]
}

/* 11 */
{
  "_id" : ObjectId("5e1ebbb930bac317c1caeda1"),
  "name" : "Black-SoftwareArr",
  "desc" : "批量卸载黑名单软件",
  "content" : "Function Black-SoftwareArr($blackList){\r\n\t$suc=0;\r\n\t$res=1|Select success,fail,isSuccess,sum,mes;\r\n\t$blackList|ConvertFrom-Csv|Foreach{\r\n\t\t$ret=Black-Software $_.softwareName $_.isAuto $_.processName $_.serviceName;$res.mes+=\"<<$_ :\"+$ret+'>>';\r\n\t\tIf(Is-Success $ret){$suc+=1}\r\n\t}\r\n\t$res.success=$suc;\r\n\t$res.sum=$blackList.length;\r\n\t$res.fail=$res.sum-$res.success\r\n\t$res.isSuccess=($suc -eq $res.sum);\r\n\tReturn $res\r\n}",
  "callContent" : "Black-SoftwareArr @(\"softwareName,isAuto,processName,serviceName\", ~blackList~);",
  "analyzingContent" : "package com.ruijie.authentication.session.program.domain.program;\r\ndialect  \"java\"\r\nimport com.ruijie.authentication.session.program.domain.program.PsScriptTemplateAnalyzingProcedureFact\r\nimport com.ruijie.authentication.authnode.domain.node.compliance.ComplianceDetectingResultState\r\nimport com.ruijie.common.utils.CsvUtil\r\nimport java.util.List\r\nrule \"classify\"\r\nwhen\r\n    fact:PsScriptTemplateAnalyzingProcedureFact()\r\nthen\r\n    fact.setResultState(ComplianceDetectingResultState.COMPLIANCE_FAIL);\r\n    String response = fact.getScriptResponse().getResponse();\r\n    List<PsBatchResult> csvData = CsvUtil.getCsvData(response, PsBatchResult.class);\r\n    if(!csvData.isEmpty()){\r\n        PsBatchResult psRetResult = csvData.get(0);\r\n        if(psRetResult.getSuccess()!=psRetResult.getSum()){\r\n            fact.setResultState(ComplianceDetectingResultState.COMPLIANCE_FAIL);\r\n        }\r\n    }\r\n    fact.setResponse(response);\r\nend",
  "subNames" : ["Black-Software", "Ret-Success", "Is-Success", "Print-Exception", "Set-Serviced", "Set-Processd", "Get-SoftwareInfoByNameVersion", "OperatorSoftwareBySWI"]
}

/* 12 */
{
  "_id" : ObjectId("5e1ebbb930bac317c1caeda2"),
  "name" : "Black-Software",
  "desc" : "卸载单个黑名单软件",
  "params" : [{
      "name" : "~softwareName~",
      "defaultValue" : "$null"
    }, {
      "name" : "~processName~",
      "defaultValue" : "$null"
    }, {
      "name" : "~isAuto~",
      "defaultValue" : "$false"
    }, {
      "name" : "~serviceName~",
      "defaultValue" : "$null"
    }],
  "content" : "Function Black-Software($softwareName,$isAuto,$processName,$serviceName){\r\n\t$business=\"[uninstall $softwareName]=>>\";\r\n\tIf([String]::isNullOrEmpty($softwareName)){Return \"BusinessException:softwareName can not empty\"}\r\n\t\r\n\t$retVal=Get-SoftwareInfoByNameVersion $softwareName $version;\r\n\tIf($retVal -eq $null){Return Ret-Success \"${business}the $softwareName is Already exist\"}\r\n\r\n\tIf([String]::isNullOrEmpty($retVal.UninstallString)){Return \"BusinessException:Uninstall command does not exist, unable to uninstall\"}\r\n\r\n\tIf(![String]::isNullOrEmpty($serviceName)){(Set-Serviced $serviceName 'Disabled' 'Stopped')|Foreach{\"$business$_\"}}\r\n\r\n\tIf(![String]::isNullOrEmpty($processName)){(Set-Processd $processName $False $startFileDir $True)|Foreach{\"$business$_\"}}\r\n\r\n\t$UninstallString=$retVal.UninstallString.Trim().ToLower();\r\n\t$iexe='msiexec.exe';\r\n\tIf($UninstallString.StartsWith($iexe)){\r\n\t\t$msicode=$UninstallString.substring($UninstallString.indexof('{'));\r\n\t\tIf($isAuto){$pra=\"/quiet\"}Else{$pra=''}\r\n\t\tInvoke-Expression \"$iexe /x `\"$msicode`\" /norestart $pra\" -ErrorAction SilentlyContinue\r\n\t\tIf(!$?){Return Print-Exception 'Invoke-Expression \"'+\"$iexe\"+ ' /x `\"'+\"$msicode\"+'`\" /norestart /quiet\"'}\r\n\t\tSleep 1\r\n\t}Else{OperatorSoftwareBySWI $hostUrl $UninstallString}\r\n\r\n\tIf((Get-SoftwareInfoByNameVersion $softwareName $version) -ne $null){Return \"BusinessException:Uninstallation has not been successful\"}\r\n\tReturn Ret-Success $business\r\n}",
  "callContent" : "",
  "subNames" : ["Ret-Success", "Is-Success", "Print-Exception", "Set-Serviced", "Set-Processd", "Get-SoftwareInfoByNameVersion", "OperatorSoftwareBySWI"]
}

