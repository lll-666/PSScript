$filepath = "namecsv.csv" 
$listas = Import-CSV $filepath -delimiter ";" 
foreach ($lista in $listas) {                      
  $db = $lista.db
  $collection = $lista.collection
  $rolename = $lista.roleName
#dev
if ($rolename -imatch '_DV_' ) {
     Connect-Mdbc -ConnectionString "mongodb+srv://username:password@onnectionstring"
                $dbc = Get-MdbcDatabase -Name $db
                Add-MdbcCollection -Name $collection -Database $dbc
                Write-Host "Collection $collection creata sul db $db di dev" -ForegroundColor Green               
}
#test
if ($rolename -imatch '_TS_') {
     Connect-Mdbc -ConnectionString "mongodb+srv://username:password@onnectionstring"
                $dbc = Get-MdbcDatabase -Name $db
                Add-MdbcCollection -Name $collection -Database $dbc    
                Write-Host "Collection $collection creata sul db $db di test" -ForegroundColor Green

}
#uat
if ($rolename -imatch '_UT_') {
     Connect-Mdbc -ConnectionString "mongodb+srv://username:password@onnectionstring"
                $dbc = Get-MdbcDatabase -Name $db
                Add-MdbcCollection -Name $collection -Database $dbc   
                Write-Host "Collection $collection creata sul db $db di uat" -ForegroundColor Green

}  
#prod
if ($rolename -imatch '_PR_') {
     Connect-Mdbc -ConnectionString "mongodb+srv://username:password@onnectionstring"
                $dbc = Get-MdbcDatabase -Name $db
                Add-MdbcCollection -Name $collection -Database $dbc
                Write-Host "Collection $collection creata sul db $db di prod" -ForegroundColor Green

}
}


Connect-Mdbc -ConnectionString "mongodb://admin:Shyfzx163@172.17.8.218:27017"
$dbc=Get-MdbcDatabase nodes
$coll=Get-MdbcCollection -Name 'plans' -Database $dbc
#Add-MdbcCollection -Name $collection -Database $dbc
