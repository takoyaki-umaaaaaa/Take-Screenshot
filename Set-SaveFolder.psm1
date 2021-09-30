# Script共通の定義・初期化処理
function scriptInitCommon() {
	Add-Type -AssemblyName system.windows.forms

	# Scriptそのものに対する定数定義
	New-Variable  -Name SCRIPT_NAME		-Value "TakeScreenshot"		-Option Constant  -Scope Global
	New-Variable  -Name SCRIPT_VERSION	-Value 0.9.0				-Option Constant  -Scope Global

	New-Variable  -Name ENV_SAVEFOLDER	-Value "TakeScreenshot_SaveToFolder"	-Option Constant  -Scope Global


	# 少しだけ今どきの Control表示にする
	[System.Windows.Forms.Application]::EnableVisualStyles()
	[System.Windows.Forms.Application]::VisualStyleState = 3

	# Win32apiをimport
	Add-Type -MemberDefinition @"
	[DllImport("user32.dll", SetLastError=true)]
	public static extern short SetThreadDpiAwarenessContext(short dpiContext);
"@ -Namespace Win32 -Name NativeMethods

	# 高DPI対応済み設定に変更(フォルダ選択ダイアログをぼやけた表示にさせないため)
	[int]$script:DpiOldSetting = [Win32.NativeMethods]::SetThreadDpiAwarenessContext(-4)
}


function scriptEndCommon() {
	# 高Dpi対応設定を元に戻す
	[void][Win32.NativeMethods]::SetThreadDpiAwarenessContext($script:DpiOldSetting)
}

# User環境変数の有無を確認
function checkUserEnvironmentValiableExists( [string]$envName )
{
	[boolean]$ret = $true
	[string]$val = [Environment]::GetEnvironmentVariable( $envName, [System.EnvironmentVariableTarget]::User )
	if( [string]::IsNullOrEmpty($val) ){
		$ret = $false
	}

	return $ret
}


# Screenshotの保存先入力用 Folder選択Dialogを表示
# 選択された場合、保存先環境変数にパスを設定する
function askToSelectSaveFolder()
{
	[boolean]$ret = $true

	$fbDlg = New-Object System.Windows.Forms.FolderBrowserDialog
	$fbDlg.Description = "Screenshotの保存先フォルダを選択してください。"
	$fbDlg.SelectedPath = $PSScriptRoot		# Default folderはひとまず Scriptがある場所にする

	# フォルダ選択ダイアログを表示
	$result = $fbDlg.ShowDialog()
	if( $result -eq [System.Windows.Forms.DialogResult]::Cancel ){
		# 環境変数を削除
		[Environment]::SetEnvironmentVariable( $global:ENV_SAVEFOLDER, $null, [System.EnvironmentVariableTarget]::User )
		$ret = $false
	}
	else {
		[Environment]::SetEnvironmentVariable( $global:ENV_SAVEFOLDER, "$($fbDlg.SelectedPath)", [System.EnvironmentVariableTarget]::User )
		$ret = $true
	}

	return $ret
}


