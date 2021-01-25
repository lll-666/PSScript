foreach($element in $input){
    if($element.Extension -eq ".exe"){
        Write-Host -fore "red" $element.Name
    }else{
        Write-Host -fore "Green" $element.Name
    }
}