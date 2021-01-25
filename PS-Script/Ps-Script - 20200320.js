db.psScriptTemplate.remove({name:"Get-InstalledSoftware"});
db.psScriptTemplate.save({
  "_id" : ObjectId("5e6f385fa0ff38f9cc08b6b1"),
  "name" : "Get-InstalledSoftware",
  "desc" : "收集终端软件信息",
  "isOpen" : true,
  "content" : "Function Get-InstalledSoftware{\r\n\t$Key='Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall','SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall';\r\n\tIf([IntPtr]::Size -eq 8){\r\n\t   $Key+='SOFTWARE\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall'\r\n\t}\r\n\t$Value='DisplayName','DisplayVersion','UninstallString','InstallLocation','RegPath','EstimatedSize','InstallDate','InstallSource','Language','ModifyPath','Publisher','icon';\r\n\tForeach($_ in $Key){\r\n\t  $Hive='LocalMachine';\r\n\t  If('Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall' -ceq $_){$Hive='CurrentUser'}\r\n\t  $RegHive=[Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($Hive,$env:COMPUTERNAME);\r\n\t  $RegKey=$RegHive.OpenSubKey($_);\r\n\t  If([string]::IsNullOrEmpty($RegKey)){Continue}\r\n\t  $RegKey.GetSubKeyNames()|ForEach{\r\n\t\t$SubKey=$RegKey.OpenSubKey($_);\r\n\t\t$retVal=1|Select-Object -Property $Value;\r\n\t\tForEach($_ in $Value){\r\n\t\t\t$tmp=$subkey.GetValue($_);\r\n\t\t\tIf(![string]::IsNullOrEmpty($tmp)){\r\n\t\t\t\tIf($tmp.gettype().name -eq 'string'){\r\n\t\t\t\t\t$retVal.$_=($tmp -replace [Regex]::UnEscape('\\u0000'), '').Replace('\"','').Replace('\\','/')\r\n\t\t\t\t}Elseif($tmp.gettype().name -eq 'int32'){\r\n\t\t\t\t\t$retVal.$_=$tmp\r\n\t\t\t\t}\r\n\t\t\t}\r\n\t\t};\r\n\t\tIf(![string]::IsNullOrEmpty($SubKey.GetValue('DisplayName'))){\r\n\t\t\t$tmp=$SubKey.Name;\r\n\t\t\tIf(![string]::IsNullOrEmpty($tmp)){\r\n\t\t\t\t$retVal.RegPath=($tmp -replace [Regex]::UnEscape('\\u0000'), '').Replace('\"','').Replace('\\','/')\r\n\t\t\t}\r\n\t\t\t$retVal\r\n\t\t}\r\n\t\t$SubKey.Close()\r\n\t  };\r\n\t  $RegHive.Close()\r\n\t}\r\n}",
  "callContent" : "Get-InstalledSoftware|ConvertTo-Csv|Select -Skip 1",
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
  "content" : "Function White-Software{\r\n\tparam([String] $hostUrl,\r\n\t\t[String] $softwareName,\r\n\t\t[String] $softwareVersion,\r\n\t\t[String] $fileName64,\r\n\t\t[String] $fileName32,\r\n\t\t[bool] $isRun =$False,\r\n\t\t[String] $processName,\r\n\t\t[String] $serviceName\r\n\t);\r\n\t$business=\"[Install $softwareName]=>>\";\r\n\tIf([String]::isNullOrEmpty($softwareName)){Return \"BusinessException:softwareName can not empty\"}\r\n\tIf((Get-SoftwareInfoByNameVersion $softwareName $softwareVersion) -ne $null){\r\n\t\tIf(!$isRun){Return Ret-Success $business}\r\n\t\tIf([String]::isNullOrEmpty($serviceName) -and [String]::isNullOrEmpty($processName)){\r\n\t\t\tReturn \"BusinessException:The software needs to be opened. The process name and service name cannot both be empty\"\r\n\t\t}\r\n\t\tIf(![String]::isNullOrEmpty($serviceName)){\r\n\t\t\t$Res = Set-Serviced $serviceName 'Automatic' 'Running';\"$business$Res\";\r\n\t\t\tIf(Is-Success $Res){Return}\r\n\t\t}\r\n\t\tIf(![String]::isNullOrEmpty($processName)){\r\n\t\t\t$Res = Set-Processd $processName $true $null;\"$business$Res\";\r\n\t\t\tIf(Is-Success $Res){Return}\r\n\t\t}\r\n\t}ElseIf($softwareName -like '*guard*'){\r\n\t\t$processName='WINRDLV3'\r\n\t\t$Res = Set-Processd $processName $true \"C:\\WINDOWS\\system32\\winrdlv3.exe\";\"$business$Res\";\r\n\t\tIf(Is-Success $Res){Return}\r\n\t}\r\n\r\n\tIf([String]::isNullOrEmpty($hostUrl)){Return \"BusinessException:hostUrl can not empty\"}\r\n\tIf([String]::isNullOrEmpty($fileName64) -and [String]::isNullOrEmpty($fileName32)){Return \"BusinessException:install package can not empty\"}\r\n\r\n\t$downloadPath = Join-Path $env:SystemDrive '/Program Files/Ruijie Networks/softwarePackage/';\r\n\tIf(!(Test-Path $downloadPath)){mkdir $downloadPath -Force|Out-Null}\r\n\r\n\tIf([IntPtr]::Size -eq 8 -and ![String]::isNullOrEmpty($fileName64)){\r\n\t\t$bit='bit64';\r\n\t\t$fileName=$fileName64;\r\n\t}Else{\r\n\t\t$bit='bit32';\r\n\t\t$fileName=$fileName32\r\n\t}\r\n\r\n\t$softwarePath = Join-Path $downloadPath $fileName;\r\n\tIf(!(Test-Path \"$softwarePath\") -or (Get-Content \"$softwarePath\" -TotalCount 1) -eq $null){\r\n\t\t$tmp=Handle-SpecialCharactersOfHTTP \"?fileName=$fileName&dir=win/$bit\";\r\n\t\t$remoteSoftwarePath=$hostUrl+'/temp'+$tmp;\r\n\t\t$Res=Download-File \"$remoteSoftwarePath\" \"$softwarePath\";\"$business$Res\";\r\n\t\tIf(!(Is-Success $Res)){Return}\r\n\t}\r\n\t$Suffix=(Get-ChildItem -Path $softwarePath).Extension.substring(1);\r\n\tIf('msi' -eq $Suffix){\r\n\t\t$os=Get-WmiObject -Class Win32_OperatingSystem | Select -ExpandProperty Caption\r\n\t\tIf($os -Like '*Windows 7*' -Or $os -Like '*Windows 8*'){\r\n\t\t\tInvoke-Expression \"& cmd /c `'msiexec.exe /i `\"$softwarePath`\"`' /qn ADVANCED_OPTIONS=1 CHANNEL=100\"\r\n\t\t}Else{\r\n\t\t\tInvoke-Expression \"Msiexec /i `\"$softwarePath`\" /norestart /qn\" -ErrorAction SilentlyContinue;\r\n\t\t\tIf(!$?){Return Print-Exception \"Msiexec /i `\"$softwarePath`\" /norestart /qn\"}\r\n\t\t}\r\n\t}else{\r\n\t\t$Res=OperatorSoftwareBySWI $hostUrl $softwarePath;\"$business$Res\";\r\n\t\tIf(!(Is-Success $Res)){Return}\r\n\t}\r\n\t\r\n\tIf((Get-SoftwareInfoByNameVersion $softwareName $softwareVersion) -eq $null){Return \"BusinessException:Installation of the software has not been successful\"}\r\n\tIf($isRun){\r\n\t\tIf(![String]::isNullOrEmpty($serviceName)){\r\n\t\t\t$Res = Set-Serviced $serviceName 'Automatic' 'Running';\"$business$Res\";\r\n\t\t\tIf(!(Is-Success $Res)){Return}\r\n\t\t}\r\n\t\tIf(![String]::isNullOrEmpty($processName)){\r\n\t\t\t$Res = Set-Processd $processName $true $startFileDir;\"$business$Res\";\r\n\t\t\tIf(!(Is-Success $Res)){Return}\r\n\t\t}\r\n\t}\r\n\tReturn Ret-Success $business\r\n}",
  "callContent" : "White-Software ~hostUrl~ ~softwareName~ ~softwareVersion~ ~fileName64~ ~fileName32~ ~isRun~ ~processName~",
  "subNames" : ["Ret-Success", "Is-Success", "Print-Exception", "Download-File", "Get-SoftwareInfoByNameVersion", "Set-Serviced", "Set-Processd", "OperatorSoftwareBySWI", "Handle-SpecialCharactersOfHTTP"],
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
  "content" : "Function Download-File([String]$src,[String]$des,[bool]$isReplace=$true){\r\n\tIf([String]::IsNullOrEmpty($src)){Return \"BusinessException:Source file does not exist\"}\r\n\tIf([String]::IsNullOrEmpty($des)){Return \"BusinessException:Destination address cannot be empty\"}\r\n\tIf(!$isReplace -And (Test-Path $des)){Return Ret-Success \"Download-File:No Need Operator\"}\r\n\tTry{\r\n\t\t$web=New-Object System.Net.WebClient;\r\n\t\t$web.Encoding=[System.Text.Encoding]::UTF8;\r\n\t\t$web.DownloadFile(\"$src\", \"$des\");\r\n\t\tIf(!(Test-Path $des) -or (Get-Content \"$des\" -totalcount 1) -eq $null){Return \"BusinessException:The downloaded file does not exist or the content is empty\"}\r\n\t}Catch{Return Print-Exception \"$web.DownloadFile($src,$des)\"}\t\r\n\tReturn Ret-Success \"Download-File\"\r\n}",
  "callContent" : "",
  "subNames" : ["Ret-Success", "Print-Exception"],
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
  "content" : "Function Get-SoftwareInfoByNameVersion([String] $name,[String] $version){\r\n\t$Key='Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall','SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall';\r\n\tIf([IntPtr]::Size -eq 8){$Key+='SOFTWARE\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall'}\r\n\tForeach($_ In $Key){\r\n\t  $Hive='LocalMachine';\r\n\t  If('Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall' -ceq $_){$Hive='CurrentUser'}\r\n\t  $RegHive=[Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($Hive,$env:COMPUTERNAME);\r\n\t  $RegKey=$RegHive.OpenSubKey($_);\r\n\t  If([string]::IsNullOrEmpty($RegKey)){Continue}\r\n\t  $arrs=$RegKey.GetSubKeyNames();\r\n\t  Foreach($_ In $arrs){\r\n\t\t$SubKey=$RegKey.OpenSubKey($_);\r\n\t\t$tmp=$subkey.GetValue('DisplayName');\r\n\t\tIf(![string]::IsNullOrEmpty($tmp)){\r\n\t\t\t$tmp=$tmp.Trim();\r\n\t\t\tIf($tmp.gettype().name -eq 'string' -And $tmp -like $name){\r\n\t\t\t\t$DisplayVersion=$subkey.GetValue('DisplayVersion');\r\n\t\t\t\tIf(![string]::IsNullOrEmpty($version) -and $version -notlike $DisplayVersion){Continue}\r\n\t\t\t\t$retVal=''|Select 'DisplayName','DisplayVersion','UninstallString','InstallLocation','RegPath','InstallDate','InstallSource';\r\n\t\t\t\t$retVal.DisplayName=$subkey.GetValue('DisplayName');\r\n\t\t\t\t$retVal.DisplayVersion=$DisplayVersion;\r\n\t\t\t\t$retVal.UninstallString=$subkey.GetValue('UninstallString');\r\n\t\t\t\t$retVal.InstallLocation=$subkey.GetValue('InstallLocation');\r\n\t\t\t\t$retVal.RegPath=$subkey.GetValue('RegPath');\r\n\t\t\t\t$retVal.InstallDate=$subkey.GetValue('InstallDate');\r\n\t\t\t\t$retVal.InstallSource=$subkey.GetValue('InstallSource');\r\n\t\t\t\tReturn $retVal;\r\n\t\t\t}\r\n\t\t}\r\n\t\t$SubKey.Close()\r\n\t  };\r\n\t  $RegHive.Close()\r\n\t};\r\n}",
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
  "content" : "Function OperatorSoftwareBySWI([String]$hostUrl,[String]$softwarePath,$isSilent=$True){\r\n\t$business=\"[OperatorSoftwareBySWI:$softwarePath]=>>\"\r\n\tIf([String]::IsNullOrEmpty(\"$softwarePath\")){\r\n\t\tReturn \"uninstall script not exist\"\r\n\t}\r\n\tIf(!$softwarePath.EndsWith(\".exe\")){\r\n\t\tReturn \"uninstall script format error[$softwarePath]\"\r\n\t}\r\n\tIf($softwarePath.StartsWith('\"')){\r\n\t\t$softwarePath=$softwarePath.substring(1,$softwarePath.LastIndexOf('\"'))\r\n\t}\r\n\t$SWIDir=Join-Path $env:SystemDrive '\\Program Files\\Ruijie Networks\\softwarePackage';\r\n\tIf(!(Test-Path $SWIDir)){\r\n\t\tmkdir $SWIDir -Force|Out-Null;\r\n\t\tIf(!$?){Return Print-Exception \"${business}mkdir $SWIDir -Force|Out-Null\"}\r\n\t}\r\n\t$SWIFileName='SWIService.exe';\r\n\t$SWIPath=Join-Path $SWIDir $SWIFileName;\r\n\t$SWIServiceName='SWIserv';\r\n\t$SWI=Get-Service -Name \"${SWIServiceName}*\"\r\n\tIf (!(Test-Path \"$SWIPath\")){\r\n\t\t$remoteexePath=$hostUrl +'/'+ $SWIFileName;\t\r\n\t\t$Res=Download-File \"$remoteexePath\" \"$SWIPath\";\"$business$Res\";\r\n\t\tIf(!(Is-Success $Res)){Return}\r\n\t}\r\n\t\r\n\tIf($null -eq $SWI){\r\n\t\tTry{\r\n\t\t\tSet-Location $SWIDir; \r\n\t\t\t.\\SWIService.exe -install -ErrorAction Stop\r\n\t\t}Catch{\r\n\t\t\tReturn Print-Exception \"${business}.\\SWIService.exe -install -ErrorAction Stop\"\r\n\t\t}\r\n\t}else{\r\n\t\tIf($SWI.Status -eq 'Running'){\r\n\t\t\tStop-Service -Name $SWIServiceName -ErrorAction SilentlyContinue;\r\n\t\t\tIf(!$?){Return Print-Exception \"${business}Stop-Service -Name $SWIServiceName\"}\r\n\t\t}\r\n\t}\r\n\tTry{\r\n\t\t$p='/s'\r\n\t\tIf(!$isSilent){$p=''}\r\n\t\t(Get-Service -Name $SWIServiceName).Start(\"{`\"exe`\":`\"$softwarePath`\",`\"arg`\":`\"$p`\"}\")\r\n\t}Catch{\r\n\t\tReturn Print-Exception \"${business}(Get-Service -Name $SWIServiceName).Start(\"+'\"{`\"exe`\":'+\"$softwarePath\"+',`\"arg`\":`\"/s`\"}\")'\r\n\t}\r\n\tReturn Ret-Success ${business}\r\n}",
  "callContent" : "OperatorSoftwareBySWI $hostUrl $softwarePath $isSilent",
  "subNames" : ["Ret-Success", "Is-Success", "Print-Exception", "Download-File"],
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
  "content" : "Function Set-Serviced($serviceName,$startType,$status){\r\n\t$business=\"[Set-Serviced $serviceName]=>>\"\r\n\t$service=Get-Service $serviceName -ErrorAction SilentlyContinue;\r\n\tIf(!$?){Return Print-Exception \"${business}Get-Service $serviceName\"}\r\n\tif($service.status -ne $status){\r\n\t\tSet-Service $serviceName -StartupType Automatic -Status $status -ErrorAction SilentlyContinue;\r\n\t\tIf(!$?){Print-Exception \"Set-Service $serviceName -Status $status\";}\r\n\t\tSleep 1\r\n\t}\r\n\t#StartupType:[Boot|System|Automatic|Manual|Disabled],Status:[Running|Stopped|Paused]\r\n\tif($service.StartupType -ne $startType){\r\n\t\tSet-Service $serviceName -StartupType $startType -ErrorAction SilentlyContinue;\r\n\t\tIf(!$?){Return Print-Exception \"${business}Set-Service $serviceName -StartupType $startType\"}\r\n\t}\t\r\n\tReturn Ret-Success $business\r\n}",
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
  "content" : "Function Set-Processd([String]$processName,[String]$isRun,[String]$startFile,[String]$isClear){\r\n\t$business=\"[Set-Processd $processName]=>>\"\r\n\tIf([String]::isNullOrEmpty($processName)){\r\n\t\tReturn \"${business}BusinessException:processName can not empty\"\r\n\t}\r\n\t\r\n\t$pro=Get-Process $processName -ErrorAction SilentlyContinue;\r\n\tIf($isRun){\r\n\t\tIf($pro -ne $null){\r\n\t\t\tReturn '${business}No Need Operator%%SMP:success'\r\n\t\t}\r\n\t\tIf([String]::isNullOrEmpty($startFile)){\r\n\t\t\tReturn \"${business}BusinessException:To start a process, The process startFile cannot be empty\";\t\r\n\t\t}\r\n\t\t\r\n\t\tIf(!(Test-Path $startFile)){\r\n\t\t\tReturn \"${business}BusinessException:[$startFile] does not exist,cannot start process\"\r\n\t\t}\r\n\t\t\r\n\t\tStart-Process $startFile -ErrorAction SilentlyContinue;\r\n\t\tIf(!$?){Return Print-Exception \"${business}Start-Process $startFile\"}\r\n\t\t\r\n\t\tReturn Ret-Success $business\r\n\t}Else{\r\n\t\tIf($pro -eq $null){\r\n\t\t\tIf($isClear){\r\n\t\t\t\tIf([String]::isNullOrEmpty($startFile)){\r\n\t\t\t\t\tReturn \"${business}BusinessException:To clean up a process, The process startFile cannot be empty\";\t\r\n\t\t\t\t}\r\n\t\t\t\tRemove-Item -Force $startFile -ErrorAction SilentlyContinue;\r\n\t\t\t\tIf(!$?){Return Print-Exception \"${business}Remove-Item -Force $startFile\"}\r\n\t\t\t}\r\n\t\t\tReturn '${business}No Need Operator%%SMP:success'\r\n\t\t}\r\n\t\t\r\n\t\t$pro|Foreach{\r\n\t\t\tStop-Process $_.Id -Force -ErrorAction SilentlyContinue;\r\n\t\t\tIf(!$?){Print-Exception \"Stop-Process $_.Id -Force\"}\r\n\t\t}\r\n\t\tSleep 1;\r\n\t\t\r\n\t\t$pro=Get-Process $processName -ErrorAction SilentlyContinue;\t\r\n\t\tIf($pro -ne $null){\r\n\t\t\tReturn \"${business}BusinessException:Failed to terminate process\"\r\n\t\t}\r\n\t\t\r\n\t\tIf($isClear){\r\n\t\t\tIf([String]::isNullOrEmpty($startFile)){\r\n\t\t\t\tReturn \"${business}BusinessException:To start a process, The process startFile cannot be empty\";\t\r\n\t\t\t}\r\n\t\t\t\r\n\t\t\tIf(!(Test-Path $startFile)){\r\n\t\t\t\tReturn \"${business}BusinessException:[$startFile] does not exist,cannot start process\"\r\n\t\t\t}\r\n\t\t\t\r\n\t\t\tRemove-Item -Force $startFile -ErrorAction SilentlyContinue;\r\n\t\t\tIf(!$?){Return Print-Exception \"Remove-Item -Force $startFile\"}\r\n\t\t}\r\n\t\tReturn ${business}\r\n\t}\r\n}",
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
  "content" : "Function Black-SoftwareArr($blackList){\r\n\t$suc=0;\r\n\t$res=1|Select success,sum,logs;\r\n\t$blackList|ConvertFrom-Csv|Foreach{\r\n\t\t$ret=Black-Software $_.softwareName $_.softwareVersion ('True' -eq $_.isAuto) $_.processName $_.serviceName;$res.logs+=\"<<$_ :\"+$ret+'>>';\r\n\t\tIf(Is-Success $ret){$suc+=1}\r\n\t}\r\n\t$res.success=$suc;\r\n\t$res.sum=$blackList.length-1;\r\n\t$tt=ConvertTo-Csv $res|Select -Skip 1\r\n\tReturn $tt\r\n}",
  "callContent" : "Black-SoftwareArr @(\"softwareName,softwareVersion,isAuto,processName,serviceName\", ~softwareList~);",
  "analyzingContent" : "package com.ruijie.authentication.session.program.domain.program;\r\ndialect  \"java\"\r\nimport com.ruijie.authentication.session.program.domain.program.PsScriptTemplateAnalyzingProcedureFact\r\nimport com.ruijie.authentication.authnode.domain.node.compliance.ComplianceDetectingResultState\r\nimport com.ruijie.common.utils.CsvUtil\r\nimport java.util.List\r\nrule \"classify\"\r\nwhen\r\n    fact:PsScriptTemplateAnalyzingProcedureFact()\r\nthen\r\n    String response = fact.getScriptResponse().getResponse();\r\n    fact.setResultState(ComplianceDetectingResultState.COMPLIANCE_FAIL);\r\n    List<PsBatchResult> csvData = CsvUtil.getCsvData(response, PsBatchResult.class);\r\n    if(!csvData.isEmpty()){\r\n        PsBatchResult psRetResult = csvData.get(0);\r\n        if(psRetResult.getSuccess()==psRetResult.getSum()){\r\n            fact.setResultState(ComplianceDetectingResultState.COMPLIANCE_SUFFICE);\r\n        }\r\n    }\r\n    fact.setResponse(response);\r\nend",
  "subNames" : ["Black-Software", "Ret-Success", "Is-Success", "Print-Exception", "Set-Serviced", "Set-Processd", "Get-SoftwareInfoByNameVersion", "OperatorSoftwareBySWI"],
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
  "content" : "Function Black-Software{\r\n\tparam(\r\n\t\t[String] $softwareName,\r\n\t\t[String] $softwareVersion,\r\n\t\t[bool] $isAuto =$true,\r\n\t\t[String] $processName,\r\n\t\t[String] $serviceName\r\n\t);\r\n\t$business=\"[uninstall $softwareName]=>>\";\r\n\tIf([String]::isNullOrEmpty($softwareName)){Return \"BusinessException:softwareName can not empty\"}\r\n\t\r\n\t$retVal=Get-SoftwareInfoByNameVersion $softwareName $softwareVersion;\r\n\tIf($retVal -eq $null){Return Ret-Success \"${business}the $softwareName is Already exist\"}\r\n\r\n\tIf([String]::isNullOrEmpty($retVal.UninstallString)){Return \"BusinessException:Uninstall command does not exist, unable to uninstall\"}\r\n\r\n\tIf(![String]::isNullOrEmpty($serviceName)){(Set-Serviced $serviceName 'Disabled' 'Stopped')|Foreach{\"$business$_\"}}\r\n\r\n\tIf(![String]::isNullOrEmpty($processName)){(Set-Processd $processName $False $startFileDir $True)|Foreach{\"$business$_\"}}\r\n\r\n\t$UninstallString=$retVal.UninstallString.Trim().ToLower();\r\n\t$iexe='msiexec.exe';\r\n\tIf($UninstallString.StartsWith($iexe)){\r\n\t\t$msicode=$UninstallString.substring($UninstallString.indexof('{'));\r\n\t\tIf($isAuto){$pra=\"/quiet\"}Else{$pra=''}\r\n\t\tInvoke-Expression \"$iexe /x `\"$msicode`\" /norestart $pra\" -ErrorAction SilentlyContinue\r\n\t\tIf(!$?){Return Print-Exception 'Invoke-Expression \"'+\"$iexe\"+ ' /x `\"'+\"$msicode\"+'`\" /norestart /quiet\"'}\r\n\t\tSleep 1\r\n\t}Else{OperatorSoftwareBySWI $hostUrl $UninstallString $isAuto}\r\n\r\n\tIf((Get-SoftwareInfoByNameVersion $softwareName $version) -ne $null){Return \"BusinessException:Uninstallation has not been successful\"}\r\n\tReturn Ret-Success $business\r\n}",
  "callContent" : "",
  "subNames" : ["Ret-Success", "Is-Success", "Print-Exception", "Set-Serviced", "Set-Processd", "Get-SoftwareInfoByNameVersion", "OperatorSoftwareBySWI"],
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
  "analyzingContent" : "package com.ruijie.authentication.session.program.domain.program;\r\ndialect  \"java\"\r\nimport com.ruijie.authentication.session.program.domain.program.PsScriptTemplateAnalyzingProcedureFact\r\nimport com.ruijie.authentication.authnode.domain.node.compliance.ComplianceDetectingResultState\r\nrule \"classify\"\r\nwhen\r\n    fact:PsScriptTemplateAnalyzingProcedureFact()\r\nthen\r\n    if(!fact.getScriptResponse().getResponse().endsWith(\"%%SMP:success\")){\r\n        fact.setResultState(ComplianceDetectingResultState.COMPLIANCE_FAIL);\r\n        fact.setResponse(fact.getScriptResponse().getResponse());\r\n    }\r\nend",
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
  "content" : "Function Get-TerminalInfo{\r\n\tFunction query($script){\r\n\t\t$arr=@();\r\n\t\t$obj=Invoke-Expression \"Get-WMIObject $script\"; \r\n\t\t$obj|Get-Member -MemberType Properties|Sort name|%{If(!$_.name.StartsWith('_')){$arr+=$_.name}}\r\n\t\t$obj|Select $arr\r\n\t}\r\n\t@{\t\r\n\t\twin32Bios=query Win32_BIOS;\r\n\t\twin32PhysicalMemoryList=query Win32_PhysicalMemory;\r\n\t\twin32Processor=query Win32_Processor;\r\n\t\twin32DiskDriveList=query Win32_DiskDrive;\r\n\t\twin32OperatingSystem=query Win32_OperatingSystem;\r\n\t\twin32LogicaldiskList=query Win32_Logicaldisk\r\n\t}\r\n}",
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
  "content" : "Function Handle-SpecialCharactersOfHTTP([String] $Characters){\r\n\tIf([String]::IsNullOrEmpty($Characters)){\r\n\t\tReturn $Null;\r\n\t}\r\n\t#[空格:%20 \":%22 #:%23 %:%25 &用%26 +:%2B ,:%2C /:%2F ::%3A ;:%3B <:%3C =:%3D >:%3E ?:%3F @:%40 \\:%5C |:%7C]\r\n\tReturn $Characters.replace(' ','%20').replace('+','%2B').replace('/','%2F')\r\n}",
  "callContent" : "Handle-SpecialCharactersOfHTTP ~Characters~",
  "subNames" : [],
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})