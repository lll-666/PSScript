function Convert-PS1ToExe{
	param(
		[Parameter(Mandatory=$true)]
		[ValidateScript({$true})]
		[ValidateNotNullOrEmpty()]
		[IO.FileInfo]$ScriptFile
	)
	if(-not $ScriptFile.Exists){Write-Warning "$ScriptFile not exits.";return}
	[string]$csharpCode = @'
	using System;
	using System.IO;
	using System.Reflection;
	using System.Diagnostics;
	namespace LoadXmlTestConsole{
	public class ConsoleWriter{
	private static void Proc_OutputDataReceived(object sender, System.Diagnostics.DataReceivedEventArgs e){
	Process pro = sender as Process;
	Console.WriteLine(e.Data);
	}
	static void Main(string[] args){
	Console.Title = "Powered by PSTips.Net";
	Assembly ase = Assembly.GetExecutingAssembly();
	string scriptName = ase.GetManifestResourceNames()[0];
	string scriptContent = string.Empty;
	using (Stream stream = ase.GetManifestResourceStream(scriptName))
	using (StreamReader reader = new StreamReader(stream)){
	scriptContent = reader.ReadToEnd();
	}
	string scriptFile = Environment.ExpandEnvironmentVariables(string.Format("%temp%\\{0}", scriptName));
	try{
	Console.WriteLine("\nLoading execution script...");
	File.WriteAllText(scriptFile, scriptContent);
	ProcessStartInfo proInfo = new ProcessStartInfo();
	proInfo.FileName = "PowerShell.exe";
	proInfo.CreateNoWindow = true;
	proInfo.RedirectStandardOutput = true;
	proInfo.UseShellExecute = false;
	proInfo.Arguments = string.Format(" -File {0}",scriptFile);
	Console.WriteLine("\nExecuting script...\n");
	var proc = Process.Start(proInfo);
	proc.OutputDataReceived += Proc_OutputDataReceived;
	proc.BeginOutputReadLine();
	proc.WaitForExit();
	Console.WriteLine("\nScript execution successful...");
	Console.WriteLine("\nHit any key to exit...");
	Console.ReadKey();
	}
	catch (Exception ex){
	Console.WriteLine("\nHit Exception: {0}", ex.Message);
	Console.WriteLine("\nHit any key to exit...");
	Console.ReadKey();
	}
	finally{
	if (File.Exists(scriptFile)){
	File.Delete(scriptFile);
	}}}}}
'@
	$providerDict = New-Object 'System.Collections.Generic.Dictionary[[string],[string]]'
	$providerDict.Add('CompilerVersion','v4.0')
	$codeCompiler = [Microsoft.CSharp.CSharpCodeProvider]$providerDict
	$compilerParameters = New-Object 'System.CodeDom.Compiler.CompilerParameters'
	$compilerParameters.GenerateExecutable = $true
	$compilerParameters.GenerateInMemory = $true
	$compilerParameters.WarningLevel = 3
	$compilerParameters.TreatWarningsAsErrors = $false
	$compilerParameters.CompilerOptions = '/optimize'
	$outputExe = Join-Path $ScriptFile.Directory "$($ScriptFile.BaseName).exe"
	$compilerParameters.OutputAssembly =  $outputExe
	$compilerParameters.EmbeddedResources.Add($ScriptFile.FullName) > $null
	$compilerParameters.ReferencedAssemblies.Add( [System.Diagnostics.Process].Assembly.Location ) > $null
	$compilerResult = $codeCompiler.CompileAssemblyFromSource($compilerParameters,$csharpCode)
	if($compilerResult.Errors.HasErrors){
		Write-Host 'Compile faield. See error message as below:' -ForegroundColor Red
		$compilerResult.Errors|foreach{Write-Warning ('{0},[{1},{2}],{3}' -f $_.ErrorNumber,$_.Line,$_.Column,$_.ErrorText)}
	}else{
		Write-Host 'Compile succeed.' -ForegroundColor Green
		"Output executable file to '$outputExe'"
	}
}