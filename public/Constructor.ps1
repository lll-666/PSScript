#获取类构造器
[String].getConstructors()|%{$_.tostring()}
<#
Void .ctor(Char*)
Void .ctor(Char*, Int32, Int32)
Void .ctor(SByte*)
Void .ctor(SByte*, Int32, Int32)
Void .ctor(SByte*, Int32, Int32, System.Text.Encoding)
Void .ctor(Char[], Int32, Int32)
Void .ctor(Char[])
Void .ctor(Char, Int32)
#>

#静态方法（对象和类 是一样的）
[String]|gm -Static  ==  "str"|gm -Static

#如下2者差异很大
[String]|gm #操作类相关信息（所有类都一样）
"str"|gm	#对象相关信息（每个对象不一样）

#调静态方法
[String]::Equals(a,b)

#调对象方法
"str0".Equals("str1")

#查看类的构造方法
[String].getConstructors()