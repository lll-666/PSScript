begin{Write-Host "管道脚本环境初始化"}
process{
    $ele=$_
    if($_.Extension -ne ""){
        switch($_.Extension.tolower()){
            ".ps1" {"脚本文件："+ $ele.name}
            ".txt" {"文本文件："+ $ele.Name}
            ".gz"  {"压缩文件："+ $ele.Name}
        }
    }
}
end{Write-Host "管道脚本环境恢复"}