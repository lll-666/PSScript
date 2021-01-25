Function Set-Processd([String]$processName,[bool]$isRun,[String]$startFile,[bool]$isClear=$false){
	$business="[Set-Processd $processName]=>>"
	If([String]::isNullOrEmpty($processName)){
		Return "${business}BusinessException:processName can not empty"
	}
	$pro=Get-Process $processName -ErrorAction SilentlyContinue
	If($isRun){
		If($pro -ne $null){
			Return "${business}No Need Operator%%SMP:success"
		}
		If([String]::isNullOrEmpty($startFile)){
			Return "${business}BusinessException:To start a process, The process startFile cannot be empty"
		}
		
		If(!(Test-Path $startFile)){
			Return "${business}BusinessException:[$startFile] does not exist,cannot start process"
		}
		
		Start-Process $startFile
		If(!$?){Return Print-Exception "${business}Start-Process $startFile"}
		Return Ret-Success $business
	}Else{
		If($pro -eq $null){
			If($isClear){
				If([String]::isNullOrEmpty($startFile)){
					Return "${business}BusinessException:To clean up a process, The process startFile cannot be empty"
				}
				rm -Force $startFile -ErrorAction SilentlyContinue
				If(!$?){Return Print-Exception "${business}rm -Force $startFile"}
			}
			Return "${business}No Need Operator%%SMP:success"
		}
		
		$pro|Foreach{
			Stop-Process $_.Id -Force -ErrorAction SilentlyContinue
			If(!$?){Return Print-Exception "Stop-Process $_.Id -Force"}
		}
		Sleep 1
		$pro=Get-Process $processName -ErrorAction SilentlyContinue
		If($pro -ne $null){
			Return "${business}BusinessException:Failed to terminate process"
		}
		
		If($isClear){
			If([String]::isNullOrEmpty($startFile)){
				Return "${business}BusinessException:To start a process, The process startFile cannot be empty"
			}
			
			If(!(Test-Path $startFile)){
				Return "${business}BusinessException:[$startFile] does not exist,cannot start process"
			}
			
			rm -Force $startFile -ErrorAction SilentlyContinue
			If(!$?){Return Print-Exception "rm -Force $startFile"}
		}
		Return Ret-Success $business
	}
}