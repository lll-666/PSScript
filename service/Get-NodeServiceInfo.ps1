ConvertToJson(Get-Service|
Sort-Object ServiceName |
Select-Object ServiceName,DisplayName,Status,ServiceType,StartType,DependentServices,ServicesDependedOn)