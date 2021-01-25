Function Read-MessageBoxDialog{
	param ([string]$Message,
	[string]$WindowTitle,
	[System.Windows.Forms.MessageBoxButtons]$Buttons = [System.Windows.Forms.MessageBoxButtons]::OK,
	[System.Windows.Forms.MessageBoxIcon]$Icon = [System.Windows.Forms.MessageBoxIcon]::None)
	Add-Type -AssemblyName System.Windows.Forms
	return [System.Windows.Forms.MessageBox]::Show($Message, $WindowTitle, $Buttons, $Icon)
}