Set-StrictMode -Version 3.0
$ErrorActionPreference = "stop"						# エラーが発生した場合はスクリプトの実行を停止

# Scriptに共通の定義
function Common_GetScriptName() 			{	return "TakeScreenshot" }
function Common_GetScriptVersion() 			{	return "0.9.0"			}
function Common_GetSettingFileName()		{	return "Settings.json"	}
function Common_GetSettingFilePath()		{	[string]$path = Join-Path "$PSScriptRoot" + Common_GetSettingFileName; return $path }

if( -not(Test-Path Variable:displayScaleValue) ){
	[double]$global:displayScaleValue = 1		# 画面の拡大率(%)
	Write-Host -ForegroundColor Yellow "displayScaleValue を初期化"
}
function GetDisplayScaleValue()				{	return $script:displayScaleValue	}
function SetDisplayScaleValue([double]$val)	{	$script:displayScaleValue = $val	}

# Win32 API を定義
function DefineWin32API() {
	Add-Type -TypeDefinition @"
	using System;
	using System.Runtime.InteropServices;

	[StructLayout(LayoutKind.Sequential)]
	public struct POINTSTRUCT {
		public int x;
		public int y;
		public POINTSTRUCT(int x, int y) {
		  this.x = x; 
		  this.y = y;
		} 
	} 
	[StructLayout(LayoutKind.Sequential)]
	public struct RECT {
		public int left;
		public int top;
		public int right;
		public int bottom;
	}
	[StructLayout(LayoutKind.Sequential,CharSet=CharSet.Auto, Pack=4)]
	public class MONITORINFO {
		public int	cbSize		= Marshal.SizeOf(typeof(MONITORINFO));
		public RECT	rcMonitor	= new RECT(); 
		public RECT	rcWork		= new RECT(); 
		public int	dwFlags		= 0;
	}
	[StructLayout(LayoutKind.Sequential,CharSet=CharSet.Auto, Pack=4)]
	public class MONITORINFOEX { 
		public int	cbSize		= Marshal.SizeOf(typeof(MONITORINFOEX));
		public RECT	rcMonitor	= new RECT(); 
		public RECT	rcWork		= new RECT(); 
		public int	dwFlags		= 0;
		[MarshalAs(UnmanagedType.ByValArray, SizeConst=32)] 
		public char[]  szDevice	= new char[32];
	}

	namespace Win32 {
		public class NativeAPIs {
			[DllImport("user32.dll", SetLastError=true)]
			public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);
			[DllImport("user32.dll", SetLastError=true)]
			public static extern IntPtr FindWindow(string lpClassName, IntPtr lpWindowName);
			[DllImport("user32.dll", SetLastError=true)]
			public static extern IntPtr FindWindow(IntPtr lpClassName, string lpWindowName);

			[DllImport("user32.dll", SetLastError=true)]
			public static extern IntPtr MonitorFromWindow(IntPtr hwnd, UInt32 dwFlags);
			[DllImport("User32.dll", SetLastError=true)]
			public static extern IntPtr MonitorFromPoint(POINTSTRUCT pt, int flags);

			[DllImport("user32.dll", SetLastError=true)]
			[return: MarshalAs(UnmanagedType.Bool)]
			public static extern bool GetMonitorInfo(IntPtr hMonitor,  [In, Out] MONITORINFOEX lpmk);

			[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
		    [DllImport("user32.dll")] public static extern int SetForegroundWindow(IntPtr hwnd);

			[DllImport("user32.dll")]
			[return: MarshalAs(UnmanagedType.Bool)]
			public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
			[DllImport("user32.dll")]
			[return: MarshalAs(UnmanagedType.Bool)]
			public static extern bool GetClientRect(IntPtr hWnd, out RECT lpRect);
			[DllImport("user32.dll")]
			[return: MarshalAs(UnmanagedType.Bool)]
			public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);

			[DllImport("user32.dll", SetLastError=true)]
			[return: MarshalAs(UnmanagedType.Bool)]
			public static extern bool ScreenToClient(IntPtr hwnd, [In, Out] POINTSTRUCT lpPoint);
			[DllImport("user32.dll", SetLastError=true)]
			[return: MarshalAs(UnmanagedType.Bool)]
			public static extern bool ClientToScreen(IntPtr hwnd, [In, Out] POINTSTRUCT lpPoint);

			[DllImport("Kernel32.dll", SetLastError=true)]
			public static extern IntPtr GetConsoleWindow();
		}
	}
"@

}



# High DPI 対応状態をWindowsに対して知らせる
function SetThreadDpiAwarenessContext([IntPtr]$dpiContext){
	# Win32apiをimport
	# High DPI 対応についての情報は以下を参照
	# https://blogs.windows.com/windowsdeveloper/2016/10/24/high-dpi-scaling-improvements-for-desktop-applications-and-mixed-mode-dpi-scaling-in-the-windows-10-anniversary-update/
	# https://docs.microsoft.com/en-us/windows/win32/hidpi/high-dpi-improvements-for-desktop-applications
	# この documentから、「設定変更→window作成」すると、そのWindowの設定は変更できないように見える
	Add-Type -MemberDefinition @"
	[DllImport("user32.dll", SetLastError=true)]
	public static extern IntPtr SetThreadDpiAwarenessContext(IntPtr dpiContext);
"@ -Namespace Win32 -Name NativeMethods

	return [Win32.NativeMethods]::SetThreadDpiAwarenessContext($dpiContext)
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
	$fbDlg.Description = "📁Screenshotの保存先フォルダを選択してください。"

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
		# 保存先未設定で呼び出された場合、Cancel押下で呼び出し元に未設定を返す必要がある
		# 存在しないパスを指定されていても、Cancel選択時はそのままで返す
		$fbDlg.SelectedPath = $path
	}

	return $fbDlg.SelectedPath
}


# まさかのPoint struct型が標準で定義されていたなんて・・・
function calcDistance([System.Windows.Point]$pt1, [System.Drawing.Point]$pt2){
	$dist = New-Object System.Drawing.Point(0, 0)
	$dist.x = [Math]::Abs($pt1.x - $pt2.x)
	$dist.x *= $dist.x
	$dist.y = [Math]::Abs($pt1.y - $pt2.y)
	$dist.y *= $dist.y
	
	$ret = $dist.x + $dist.y
	# 一律√計算はせずに使う
	return $ret
}



# Screenshot を撮る
# 
function TakeScreenshot(
							[int]$targetDisplay = 0,
							[string]$destFilePath)
{
	begin {	# 1回だけやっておけばいいような処理を記載。For-Each objectで呼ばれると、ループ処理開始前に1回呼ばれる。
		Write-Host "`n---------- TakeScreenshot ------------------------------------------"
		Write-Host "Target screen : $([string]$targetDisplay)"
		Write-Host "Destination file : $destFilePath"
	}

	process{
		# 全画面情報取得
		[object]$Screens = [System.Windows.Forms.Screen]::AllScreens

		Write-Host "Display count : $($Screens.length)"
		if( $targetDisplay -gt ($Screens.length - 1) ){
			Write-Host -ForegroundColor Red "`n画面保存対象として、存在しない画面を指定しています。存在する画面数は $($Screens.length) です。"
			exit -1
		}

		# 取得した画面情報ごとに、作業領域の座標を取得
		foreach( $screen in $Screens ){
			if( $screen.Primary -eq $true ){
				Write-Host ""
				Write-Host "Primary Display"
				Write-Host "Device Name = $($screen.DeviceName)"
				Write-Host "WorkingArea.Left = $($screen.WorkingArea.Left), Top = $($screen.WorkingArea.Top), Width = $($screen.WorkingArea.Width), Height = $($screen.WorkingArea.Height)"

				[string]$primaryName	= $screen.DeviceName
				[int]$primaryLeft		= $screen.WorkingArea.Left
				[int]$primaryTop		= $screen.WorkingArea.Top
				[int]$primaryWidth		= $screen.WorkingArea.Width
				[int]$primaryHeight		= $screen.WorkingArea.Height
			}
			else {
				Write-Host ""
				Write-Host "Other Display"
				Write-Host "Device Name = $($screen.DeviceName)"
				Write-Host "WorkingArea.Left = $($screen.WorkingArea.Left), Top = $($screen.WorkingArea.Top), Width = $($screen.WorkingArea.Width), Height = $($screen.WorkingArea.Height)"

				# Primaryでないなら Secondary決め打ち。Primary以外の propertyが無いから。1PCに3画面以上が標準になれば propertyが増えるのだろうか・・・
				# 2画面以上接続していると画面が見つかる度に情報を上書きされる。なのでSecondaryとしては「最後に見つかった画面の情報」が残る。
				[int]$secondaryLeft		= $screen.WorkingArea.Left
				[int]$secondaryTop		= $screen.WorkingArea.Top
				[int]$secondaryWidth	= $screen.WorkingArea.Width
				[int]$secondaryHeight	= $screen.WorkingArea.Height
			}
		}

		if( $targetDisplay -eq 0 ){
			[int]$targetLeft	= $primaryLeft
			[int]$targetTop		= $primaryTop
			[int]$targetWidth	= $primaryWidth
			[int]$targetHeight	= $primaryHeight
		}
		else {
			[int]$targetLeft	= $secondaryLeft
			[int]$targetTop		= $secondaryTop
			[int]$targetWidth	= $secondaryWidth
			[int]$targetHeight	= $secondaryHeight
		}
		

		[object]$bitmap = New-Object System.Drawing.Bitmap( $targetWidth, $targetHeight )	# Screenshotを撮る領域サイズのbitmap objctを作成
		[object]$image = [System.Drawing.Graphics]::FromImage( $bitmap )					# Screen image取得用に image objectを作成
		$image.CopyFromScreen( (New-Object System.Drawing.Point($targetLeft,$targetTop)), (New-Object System.Drawing.Point(0,0)), $bitmap.size )
		$image.Dispose()																	# Graphics resource廃棄
		$bitmap.Save( $destFilePath )
	}

	end {	# 1回だけやっておけばいいような処理を記載。For-Each objectで呼ばれると、ループ処理終了後に1回呼ばれる。
		return $destFilePath
	}
}

# 設定関係。別ファイルにするかも =================================

# 設定情報保持object。ひとまずDefault設定で作成しておく。
[PSCustomObject]$script:Settings = [PSCustomObject]@{
	"ImageSaveDestination"			= ""
	"PreviewImageAfterSaving"		= "Yes"
	"DisplayButtonOnPreviewImage"	= "Yes"
}
# 設定保持object作成
function Setting_GetSettingInfoFilePath(){
	$settingfilepath = Join-Path "$PSScriptRoot" ".\Settings.json"
	return $settingfilepath
}
function Setting_Load(){
	# ファイルの存在チェック
	$filepath = Setting_GetSettingInfoFilePath
	if( -not (Test-Path $filepath -PathType leaf) ){
		# 設定ファイルなしのため default設定とする
		Write-Host -ForegroundColor Yellow "設定ファイルが見つからないためデフォルト設定にします"
		
		# Default設定で設定ファイルを作成
		Setting_Save
	}
	else {
		# 読み込み
		$script:Settings = Get-Content $filepath -Encoding UTF8 -Raw | ConvertFrom-Json
	}
	
}
function Setting_Save(){
	$filepath = Setting_GetSettingInfoFilePath
	$script:Settings | ConvertTo-Json | Out-File -Encoding UTF8 -FilePath $filepath
}

# Screenshotの保存先パスを取得
function Setting_GetImageSaveFolder(){
	return $script:Settings.ImageSaveDestination
}
# Screenshotの保存先パスを設定
function Setting_SetImageSaveFolder([string]$path){
	$script:Settings.ImageSaveDestination = $path
}

# Screenshotを保存後に表示するかどうかの設定情報
function Setting_GetOption_DisplaySavedPicture(){
	[boolean]$ret = $false
	if( "Yes" -eq $script:Settings.PreviewImageAfterSaving){
		$ret = $true
	}
	
	return $ret
}
function Setting_SetOption_DisplaySavedPicture([boolean]$disp){
	if( $disp ){
		$script:Settings.PreviewImageAfterSaving = "Yes"
	}
	else {
		$script:Settings.PreviewImageAfterSaving = "No"
	}
}

