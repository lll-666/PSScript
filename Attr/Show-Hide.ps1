#显示当前目录下所有文件及目录(不包含隐藏文件)
ls -Path $home
#显示当前目录下所有文件及目录(包含隐藏文件)
ls -Path $home -Force
#显示当前目录及子孙目录下所有文件及目录(包含隐藏文件)
ls -Path C:\ -Force -Recurse
#查看当前目录下隐藏文件
ls -Path $home -Hidden

#切换到目标目录
cd "C:\Program Files\Ruijie Networks"
#隐藏当前及子孙目录下所有的文件
attrib +s +r +h /s /d
attrib +s +r +h /s /d  "C:\Program Files\Ruijie Networks\*"

#显示当前目录下所有的文件
cd "C:\Program Files\Ruijie Networks"
attrib -s -r -h /d
attrib -s -r -h "C:\Program Files\Ruijie Networks"

attrib +s  +h  /d  "C:\Program Files\Ruijie Networks\*"