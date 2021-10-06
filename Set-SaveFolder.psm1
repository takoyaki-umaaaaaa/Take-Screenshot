Set-StrictMode -Version 3.0
$ErrorActionPreference = "stop"						# エラーが発生した場合はスクリプトの実行を停止


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
	# High DPI 対応についての情報は以下を参照
	# https://blogs.windows.com/windowsdeveloper/2016/10/24/high-dpi-scaling-improvements-for-desktop-applications-and-mixed-mode-dpi-scaling-in-the-windows-10-anniversary-update/
	# https://docs.microsoft.com/en-us/windows/win32/hidpi/high-dpi-improvements-for-desktop-applications
	# この documentから、「設定変更→window作成」すると、そのWindowの設定は変更できないように見える
	Add-Type -MemberDefinition @"
	[DllImport("user32.dll", SetLastError=true)]
	public static extern IntPtr SetThreadDpiAwarenessContext(IntPtr dpiContext);
"@ -Namespace Win32 -Name NativeMethods

	[IntPtr]$script:DpiOldSetting = [Win32.NativeMethods]::SetThreadDpiAwarenessContext(-4)
	Write-Host "DpiOldSetting : $($script:DpiOldSetting)-----------------"
	$aaa = [System.Windows.Forms.Screen]::AllScreens
	Write-Host "$aaa"
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
function askToSelectSaveFolder([string]$path)
{
	[object]$fbDlg = New-Object System.Windows.Forms.FolderBrowserDialog
	$fbDlg.Description = "Screenshotの保存先フォルダを選択してください。"

	# Dlg初期フォルダ設定：存在しないフォルダが指定されている場合はスクリプトが保存されているフォルダを指すようにする
	if( [string]::IsNullOrEmpty($path) ){
		$fbDlg.SelectedPath = $PSScriptRoot
	}
	elseif( -not (Test-Path -Path $path -PathType Container) ){
		$fbDlg.SelectedPath = $PSScriptRoot
	}
	else {
		$fbDlg.SelectedPath = $path
	}


	# フォルダ選択ダイアログを表示
	[System.Windows.Forms.DialogResult]$result = $fbDlg.ShowDialog()
	if( $result -eq [System.Windows.Forms.DialogResult]::Cancel ){
		# 未設定で呼び出された場合、未設定を返す必要がある
		# 存在しないパスを指定されていても、Cancel選択時はそのままで返す
		$fbDlg.SelectedPath = $path
	}
	else {
		[Environment]::SetEnvironmentVariable( $global:ENV_SAVEFOLDER, "$($fbDlg.SelectedPath)", [System.EnvironmentVariableTarget]::User )
	}

	return $fbDlg.SelectedPath
}


