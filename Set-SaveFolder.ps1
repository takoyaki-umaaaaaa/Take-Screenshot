Add-Type -AssemblyName system.windows.forms




# 少しだけ今どきの Control表示にする
[System.Windows.Forms.Application]::EnableVisualStyles()
[System.Windows.Forms.VisualStyles]::VisualStyleState = 0

# Win32apiをimport
Add-Type -MemberDefinition @"
[DllImport("user32.dll", SetLastError=true)]
public static extern short SetThreadDpiAwarenessContext(short dpiContext);
"@ -Namespace Win32 -Name NativeMethods

# 高DPI対応済み設定に変更(フォルダ選択ダイアログをぼやけた表示にさせないため)
[int]$DpiOldSetting = [Win32.NativeMethods]::SetThreadDpiAwarenessContext(-4)

[System.Windows.Forms.MessageBox]::Show("This is my msgbox")

$fbDlg = New-Object System.Windows.Forms.FolderBrowserDialog
$fbDlg.Description = "画像を保存するフォルダを選択してください。"
$fbDlg.SelectedPath = $PSScriptRoot		# Default folderはひとまず Scriptがある場所にする

# フォルダ選択ダイアログを表示
$result = $fbDlg.ShowDialog()
if( $result -eq [System.Windows.Forms.DialogResult]::Cancel ){
	$saveFolderPath = $null
}
else {
	$saveFolderPath = $fbDlg.SelectedPath
	[Environment]::SetEnvironmentVariable( "TakeScreenshot_SaveToFolder", "$($fbDlg.SelectedPath)", 1 )
}

Write-Host $saveFolderPath
