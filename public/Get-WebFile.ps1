function Get-WebFile {
<# Author:fuhj(powershell#live.cn ,http://fuhaijun.com) 
   Downloads a file or page from the web
.Example
  Get-WebFile http://mirrors.cnnic.cn/apache/couchdb/binary/win/1.4.0/setup-couchdb-1.4.0_R16B01.exe
  Downloads the latest version of this file to the current directory
#>
[CmdletBinding(DefaultParameterSetName="NoCredentials")]
   param(
      #  The URL of the file/page to download
      [Parameter(Mandatory=$true,Position=0)]
      [System.Uri][Alias("Url")]$Uri # = (Read-Host "The URL to download")
   ,
      #  A Path to save the downloaded content. 
      [string]$FileName
   ,
      #  Leave the file unblocked instead of blocked
      [Switch]$Unblocked
   ,
      #  Rather than saving the downloaded content to a file, output it.  
      #  This is for text documents like web pages and rss feeds, and allows you to avoid temporarily caching the text in a file.
      [switch]$Passthru
   ,
      #  Supresses the Write-Progress during download
      [switch]$Quiet
   ,
      #  The name of a variable to store the session (cookies) in
      [String]$SessionVariableName
   ,
      #  Text to include at the front of the UserAgent string
      [string]$UserAgent = "PowerShellWget/$(1.0)"
   )
   Write-Verbose "Downloading &#39;$Uri'"
   $EAP,$ErrorActionPreference = $ErrorActionPreference, "Stop"
   $request = [System.Net.HttpWebRequest]::Create($Uri);
   $ErrorActionPreference = $EAP
   $request.UserAgent = $(
         "{0} (PowerShell {1}; .NET CLR {2}; {3}; http://fuhaijun.com)" -f $UserAgent,
         $(if($Host.Version){$Host.Version}else{"1.0"}),
         [Environment]::Version,
         [Environment]::OSVersion.ToString().Replace("Microsoft Windows ", "Win")
      )
   $Cookies = New-Object System.Net.CookieContainer
   if($SessionVariableName) {
      $Cookies = Get-Variable $SessionVariableName -Scope 1
   }
   $request.CookieContainer = $Cookies
   if($SessionVariableName) {
      Set-Variable $SessionVariableName -Scope 1 -Value $Cookies
   }
   try {
      $res = $request.GetResponse();
   } catch [System.Net.WebException] {
      Write-Error $_.Exception -Category ResourceUnavailable
      return
   } catch {
      Write-Error $_.Exception -Category NotImplemented
      return
   }
   if((Test-Path variable:res) -and $res.StatusCode -eq 200) {
      if($fileName -and !(Split-Path $fileName)) {
         $fileName = Join-Path (Convert-Path (Get-Location -PSProvider "FileSystem")) $fileName
      }elseif((!$Passthru -and !$fileName) -or ($fileName -and (Test-Path -PathType "Container" $fileName))){
         [string]$fileName = ([regex]'&#40;?i)filename=(.*)$').Match( $res.Headers["Content-Disposition"] ).Groups[1].Value
         $fileName = $fileName.trim("&#92;/""'")
         $ofs = ""
         $fileName = [Regex]::Replace($fileName, "[$([Regex]::Escape(""$([System.IO.Path]::GetInvalidPathChars())$([IO.Path]::AltDirectorySeparatorChar)$([IO.Path]::DirectorySeparatorChar)""))]", "_")
         $ofs = " "
         if(!$fileName) {
            $fileName = $res.ResponseUri.Segments[-1]
            $fileName = $fileName.trim("\/")
            if(!$fileName) {
               $fileName = Read-Host "Please provide a file name"
            }
            $fileName = $fileName.trim("\/")
            if(!([IO.FileInfo]$fileName).Extension) {
               $fileName = $fileName + "." + $res.ContentType.Split(";")[0].Split("/")[1]
            }
         }
         $fileName = Join-Path (Convert-Path (Get-Location -PSProvider "FileSystem")) $fileName
      }
      if($Passthru) {
         $encoding = [System.Text.Encoding]::GetEncoding( $res.CharacterSet )
         [string]$output = ""
      }
      [int]$goal = $res.ContentLength
      $reader = $res.GetResponseStream()
      if($fileName) {
         try {
            $writer = new-object System.IO.FileStream $fileName, "Create"
         } catch {
            Write-Error $_.Exception -Category WriteError
            return
         }
      }
      [byte[]]$buffer = new-object byte[] 4096
      [int]$total = [int]$count = 0
      do{
         $count = $reader.Read($buffer, 0, $buffer.Length);
         if($fileName) {
            $writer.Write($buffer, 0, $count);
         }
         if($Passthru){
            $output += $encoding.GetString($buffer,0,$count)
         } elseif(!$quiet) {
            $total += $count
            if($goal -gt 0) {
               Write-Progress "Downloading $Uri" "Saving $total of $goal" -id 0 -percentComplete (($total/$goal)*100)
            } else {
               Write-Progress "Downloading $Uri" "Saving $total bytes..." -id 0
            }
         }
      } while ($count -gt 0)
      $reader.Close()
      if($fileName) {
         $writer.Flush()
         $writer.Close()
      }
      if($Passthru){
         $output
      }
   }
   if(Test-Path variable:res) { $res.Close(); }
   if($fileName) {
      ls $fileName
   }
}