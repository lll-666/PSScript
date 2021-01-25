db.psScriptTemplate.remove({name:"Dangerous-Port"});
db.psScriptTemplate.save({
  "_id" : ObjectId("5e68a7fc5448f543905f4beb"),
  "name" : "Dangerous-Port",
  "desc" : "高危端口",
  "isOpen" : true,
  "content" : "Function Dangerous-Port{\r\n    param(\r\n        [int] $port,\r\n        [String] $protocol,\r\n        [ValidateSet('allow','block')][String] $action\r\n    )\r\n    $ruleName='SmpPlus-'+$protocol+$port+$action;\r\n    If((netsh advfirewall firewall show rule name=$ruleName).Count -lt 4){#行数小于4,说明没有记录的\r\n        netsh advfirewall firewall add rule name=$ruleName profile=any dir=out protocol=$protocol localport=$port action=$action;\r\n        If((netsh advfirewall firewall show rule name=$ruleName).Count -lt 4){ \r\n            \"%%SMP:executing-fail\"\r\n        } else{ \r\n            \"%%SMP:executing-suffice\"\r\n        } \r\n    }Else{\r\n        \"%%SMP:detecting-suffice\"\r\n    }\r\n}",
  "callContent" : "Dangerous-Port ~port~ ~protocol~ ~action~",
  "params" : [{
      "name" : "~port~",
      "type" : "string"
    }, {
      "name" : "~protocol~",
      "defaultValue" : "TCP",
      "type" : "string"
    }, {
      "name" : "~action~",
      "defaultValue" : "block",
      "type" : "string"
    }],
  "analyzingContent" : "package pstemplates.dangerousport;\r\ndialect  \"mvel\"\r\n\r\nimport com.ruijie.authentication.session.program.domain.program.PsScriptTemplateAnalyzingProcedureFact;\r\nimport com.ruijie.authentication.authnode.domain.node.LabelValue;\r\nimport com.ruijie.authentication.authnode.domain.node.compliance.ComplianceDetectingResultState;\r\nimport com.ruijie.authentication.authnode.domain.label.LabelConstant;\r\n\r\nrule \"analyzingScript\"\r\n    when\r\n        $fact: PsScriptTemplateAnalyzingProcedureFact($node: node, $scriptResponse: scriptResponse, $labels: updateLabels)\r\n    then\r\n        if ($scriptResponse.isError() || $scriptResponse.isTimeout()){\r\n            $fact.setResultState(ComplianceDetectingResultState.EXCEPTION_SUFFICE);\r\n            $fact.setOperateRecord(\"执行异常或执行操作，默认合规\");\r\n        } else {\r\n            String response = $scriptResponse.getResponse();\r\n            String result = response.substring(response.indexOf(\"%%SMP:\") + 6);\r\n            String resultInfo = response.substring(response.indexOf(\"%%RESULT:\") + 9);\r\n\r\n            if (result.contains(\"detecting-suffice\") || result.contains(\"executing-suffice\")){\r\n                 $fact.setResultState(ComplianceDetectingResultState.COMPLIANCE_SUFFICE);\r\n                 $fact.setOperateRecord(\"端口\" + resultInfo + \"已禁用！\");\r\n            }else if(result.contains(\"executing-fail\")){\r\n                 $fact.setResultState(ComplianceDetectingResultState.COMPLIANCE_FAIL);\r\n                 $fact.setOperateRecord(\"端口\" + resultInfo + \"禁用失败！\");\r\n            } else {\r\n                 $fact.setResultState(ComplianceDetectingResultState.COMPLIANCE_SUFFICE);\r\n                 $fact.setOperateRecord(\"内部异常，默认合规！\");\r\n            }\r\n        }\r\nend\r\n",
  "_version_" : "0",
  "createTime" :new Date(),
  "lastModifiedTime" :new Date(),
  "_class" : "com.ruijie.authentication.session.program.domain.program.PsScriptTemplate"
})