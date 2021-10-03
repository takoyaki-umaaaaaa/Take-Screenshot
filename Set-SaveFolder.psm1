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

function conv-ver() {
	Add-Type -AssemblyName System.Drawing

	Write-Host "call"
	# Win32apiをimport
	Add-Type -MemberDefinition @"
	[StructLayout(LayoutKind.Sequential)]
	struct RECT {
		public int left;
		public int top;
		public int right;
		public int bottom;
	}
	[StructLayout(LayoutKind.Sequential)]
	struct MONITORINFO {
		public UInt32	cbSize;
		public RECT		rcMonitor;
		public RECT		rcWork;
		public UInt32	dwFlags;
	}
	[DllImport("user32.dll", SetLastError=true)]
	public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);
	[DllImport("user32.dll", SetLastError=true)]
	public static extern IntPtr FindWindow(string lpClassName, IntPtr lpWindowName);
	[DllImport("user32.dll", SetLastError=true)]
	public static extern IntPtr FindWindow(IntPtr lpClassName, string lpWindowName);

	[DllImport("user32.dll", SetLastError=true)]
	public static extern IntPtr MonitorFromWindow(IntPtr hwnd, UInt32 dwFlags);

	[DllImport("user32.dll", SetLastError=true)]
	[return: MarshalAs(UnmanagedType.Bool)]
	public static extern bool GetMonitorInfo(IntPtr hMonitor, ref IntPtr lpmk);

"@ -Namespace Win32 -Name NativeDPIs

	Write-Host "findwindow"
	[IntPtr]$hWnd = [Win32.NativeDPIs]::FindWindow( [IntPtr]::Zero, "先ほど撮ったScreenshot画像を表示")
	Write-Host "HWND = $hWnd"
	[IntPtr]$hMonitor = [Win32.NativeDPIs]::MonitorFromWindow( $hWnd, 2 )
	Write-Host "HMONITOR = $hMonitor"

	$info = New-Object Win32.NativeDPIs.MONITORINFO

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
	$fbDlg = New-Object System.Windows.Forms.FolderBrowserDialog
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
	$result = $fbDlg.ShowDialog()
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


