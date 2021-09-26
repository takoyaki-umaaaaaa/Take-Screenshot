Add-Type -AssemblyName system.windows.forms

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
