Add-Type -AssemblyName system.windows.forms

$fbDlg = New-Object System.Windows.Forms.FolderBrowserDialog
$fbDlg.Description = "�摜��ۑ�����t�H���_��I�����Ă��������B"
$fbDlg.SelectedPath = $PSScriptRoot		# Default folder�͂ЂƂ܂� Script������ꏊ�ɂ���

# �t�H���_�I���_�C�A���O��\��
$result = $fbDlg.ShowDialog()
if( $result -eq [System.Windows.Forms.DialogResult]::Cancel ){
	$saveFolderPath = $null
}
else {
	$saveFolderPath = $fbDlg.SelectedPath
	[Environment]::SetEnvironmentVariable( "TakeScreenshot_SaveToFolder", "$($fbDlg.SelectedPath)", 1 )
}

Write-Host $saveFolderPath
