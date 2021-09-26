Add-Type -AssemblyName system.windows.forms




# �����������ǂ��� Control�\���ɂ���
[System.Windows.Forms.Application]::EnableVisualStyles()
[System.Windows.Forms.VisualStyles]::VisualStyleState = 0

# Win32api��import
Add-Type -MemberDefinition @"
[DllImport("user32.dll", SetLastError=true)]
public static extern short SetThreadDpiAwarenessContext(short dpiContext);
"@ -Namespace Win32 -Name NativeMethods

# ��DPI�Ή��ςݐݒ�ɕύX(�t�H���_�I���_�C�A���O���ڂ₯���\���ɂ����Ȃ�����)
[int]$DpiOldSetting = [Win32.NativeMethods]::SetThreadDpiAwarenessContext(-4)

[System.Windows.Forms.MessageBox]::Show("This is my msgbox")

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
