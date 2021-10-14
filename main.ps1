# Screenshotを撮る
# 保存領域：指定したDisplayから Taskbarを除いた領域を撮る

# Requires -Version 5.0

param(
		[Parameter( ValueFromPipeline = $true )]
		[int]$targetDisplayNumber = 0,				# 0:Primary, 1:Secondary, ...

		[Parameter()][AllowEmptyString()]
		[string]$outputDirectory,					# 保存先フォルダ(未指定：folder選択dialog表示)

		[Parameter()][AllowEmptyString()]
		[string]$outputFileName						# 保存するファイル名(未指定：年月日-時分秒.png)
)

. $PSScriptRoot\Utilities.ps1
Import-Module -Name $PSScriptRoot\DisplayPicture.psm1
Import-Module -Name $PSScriptRoot\dummyWindow.psm1

# 環境設定
Set-StrictMode -Version 3.0
$ErrorActionPreference = "stop"						# エラーが発生した場合はスクリプトの実行を停止
$PSDefaultParameterValues['out-file:width'] = 2000	# Script実行中は1行あたり2000文字設定

Add-Type -AssemblyName System.Windows.Forms
# 少しだけ今どきの Control表示にする
[System.Windows.Forms.Application]::EnableVisualStyles()
[System.Windows.Forms.Application]::VisualStyleState = 3

# Script title 出力
[string]$SCRIPT_NAME = Common_GetScriptName
[string]$SCRIPT_VERSION = Common_GetScriptVersion
Write-Host -ForegroundColor Yellow "`n---- $SCRIPT_NAME   version $SCRIPT_VERSION ----"

# 使用するWin32 APIを定義
DefineWin32API

[IntPtr]$hConsoleWnd = [Win32.NativeAPIs]::GetConsoleWindow()
Write-Host "Console hwnd = $hConsoleWnd"


# Window作成前に呼ぶことで、これ以降にこのScriptで作られる
# Top Level windowが High DPI対応として動作する
# ここでは、画面解像度値取得のために設定している
$script:DpiAwareness = SetThreadDpiAwarenessContext(-4)
# 画面用設定を反映させるため、dummy window を作成し、すぐに破棄する
displayDummyWindow -hParentwnd $hConsoleWnd

# 全モニタの数と解像度を保持しておく
[object]$Screens = [System.Windows.Forms.Screen]::AllScreens
Write-Host "$Screens"

if( $targetDisplayNumber -ge $Screens.Length  ){
	[string]$errstr = "Screenshot取得先の画面番号指定(指定=$targetDisplayNumber)が誤っています。`n接続されている画面は$($Screens.Length)のため、`n0 ～ ($($Screens.Length)-1) の範囲で指定してください。"
	[System.Windows.Forms.MessageBox]::Show($errstr, "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Stop)
	Write-Host -ForegroundColor Red "$errstr"
	exit -1
}

# Display Scaling Value を得るために child windowを作る(RectでなくPointなのは、幅高さをもらうため)
$Resolution_Scale	= New-Object System.Windows.Point
$Resolution_Pixcel	= New-Object System.Windows.Point
$rcWorkarea_Scale		= New-Object System.Windows.Point
$rcWorkarea_Pixcel	= New-Object System.Windows.Point

[IntPtr]$script:DpiOldSetting = SetThreadDpiAwarenessContext(-1)
displayDummyWindow 0 ([ref]$Resolution_Scale) ([ref]$rcWorkarea_Scale)

[IntPtr]$script:DpiOldSetting = SetThreadDpiAwarenessContext(-4)
displayDummyWindow 0 ([ref]$Resolution_Pixcel) ([ref]$rcWorkarea_Pixcel)

Write-Host "$($Resolution_Scale.x)  $($Resolution_Scale.y)"
Write-Host "$($Resolution_Pixcel.x)  $($Resolution_Pixcel.y)"

[double]$scale = ($Resolution_Pixcel.x) / $Resolution_Scale.x
Write-Host -ForegroundColor Yellow "`n画面の拡大率は $scale %です。"
SetDisplayScaleValue( $scale )			# 拡大率を保持

# 保存先が未設定であれば、保存先フォルダ選択ダイアログで選択してもらう
if( [string]::IsNullOrEmpty($outputDirectory) ){
	[boolean]$result = checkUserEnvironmentValiableExists $global:ENV_SAVEFOLDER
	if( $result -eq $false ){
		[boolean]$ret = askToSelectSaveFolder
		if( $ret -eq $false ){
			exit 0
		}
		[string]$outputDirectory = [Environment]::GetEnvironmentVariable( $global:ENV_SAVEFOLDER, [System.EnvironmentVariableTarget]::User )
	}
}

# Screenshot取得先フォルダ、ファイル名を確認
if( -not (Test-Path -Path $outputDirectory -PathType Container) ){Write-Host -ForegroundColor Red "`n保存先のフォルダ($outputDirectory)が見つかりません。正しいフォルダ名を指定してください。"; exit -1}
if( [string]::IsNullOrEmpty($outputFileName) ){
	# ファイル名が未指定の場合は「年月日-時分秒」をファイル名とする
	$outputFileName = Get-Date -Format yyyyMMdd-HHmmss
	$outputFileName = $outputFileName + ".png"
}
[string]$destFilePath = Join-Path $outputDirectory $outputFileName
if( Test-Path -Path $destFilePath -PathType Leaf ){
	$Ans = Read-Host "`n指定のファイルは既に存在しています。`n上書きしてもよろしいですか？(Y/N)"
	if( $Ans -ne "Y" ){Write-Host "`n別ファイル名を指定してください"; exit 0}
}


# Screenshotを撮る
[string]$screenshotFilePath = TakeScreenshot $targetDisplayNumber $destFilePath

if( [string]::IsNullOrEmpty($screenshotFilePath) ){
	# Screenshotに失敗
	[string]$errstr = "Screenshotの保存に失敗しました"
	[System.Windows.Forms.MessageBox]::Show($errstr)
	Write-Host -ForegroundColor Red "$errstr"
	exit -1
}
else {
	# 撮った画像を表示する
	ShowPicture $screenshotFilePath
}
