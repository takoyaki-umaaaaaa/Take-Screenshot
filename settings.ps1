# 設定画面を起動
# 保存先フォルダを設定した場合、User環境変数に保持する
# (そのためregistryに内容が保持される)

# Requires -Version 5.0
. $PSScriptRoot\Utilities.ps1
Import-Module -Name $PSScriptRoot\dummyWindow.psm1

Add-Type -AssemblyName system.windows.forms
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName system

# 環境設定
Set-StrictMode -Version 3.0
$ErrorActionPreference = "stop"						# エラーが発生した場合はスクリプトの実行を停止
$PSDefaultParameterValues['out-file:width'] = 2000	# Script実行中は1行あたり2000文字設定

Add-Type -AssemblyName system.windows.forms
# 少しだけ今どきの Control表示にする
[System.Windows.Forms.Application]::EnableVisualStyles()
[System.Windows.Forms.Application]::VisualStyleState = 3

# Window作成前に呼ぶことで、これ以降にこのScriptで作られる
# Top Level windowが High DPI対応として動作する
$script:DpiAwareness = SetThreadDpiAwarenessContext(-4)

# 設定情報を読み込む
Setting_Load

# 設定dialogを読み込み
Import-Module -Name $PSScriptRoot\SettingWindow.psm1
#[xml]$xaml = Get-Content ($PSScriptRoot + "\SettingWindow.xaml")
[xml]$xaml  = $global:SettingDlgXaml
$xamlReader = $xaml -as "System.Xml.XmlNodeReader"
$SettingWnd = [Windows.Markup.XamlReader]::Load( $xamlReader )


# Control elementの objectを取得
[int]$cnt = 0
foreach( $ctl in $global:Controls ){
	Write-Host "Element name ($($global:Controls[$cnt].Name))のobjectを探す"
	$global:Controls[$cnt].Element = $SettingWnd.FindName( $global:Controls[$cnt].Name )
	$cnt++
}
$baseWnd = $SettingWnd.FindName( "baseWindow" )

# 保存先フォルダの設定状態を表示
[string]$saveFolder = Setting_GetImageSaveFolder
$global:Controls[2].Element.Text = $saveFolder
# 保存後に画像を表示
[boolean]$displayImage = Setting_GetOption_DisplaySavedPicture
$global:Controls[5].Element.IsChecked = $displayImage

# Event handler登録
$global:Controls[3].Element.Add_Click({$ret = askToSelectSaveFolder $global:Controls[2].Element.Text; Setting_SetImageSaveFolder $ret; $global:Controls[2].Element.Text = $ret})		# 保存先指定Dialogを開くボタン
$global:Controls[4].Element.Add_Click({Setting_SetImageSaveFolder "";  $global:Controls[2].Element.Text = $null})	# 保存先設定を削除するボタン
$global:Controls[8].Element.Add_Click({
	# [閉じる]ボタン
	Setting_SetOption_DisplaySavedPicture $global:Controls[5].Element.IsChecked
	Setting_Save
	$SettingWnd.Close()
})

$baseWnd.add_Loaded({
	$script:hwndSetting = (New-Object System.Windows.Interop.WindowInteropHelper($this)).Handle
	Write-Host "hwndSetting = $hwndSetting"


	[IntPtr]$script:DpiOldSetting = SetThreadDpiAwarenessContext(-1)
	displayDummyWindow $script:hwndSetting

	[IntPtr]$script:DpiOldSetting = SetThreadDpiAwarenessContext(-4)
	displayDummyWindow $script:hwndSetting

	SetThreadDpiAwarenessContext($script:DpiOldSetting)

	[object]$Screens = [System.Windows.Forms.Screen]::AllScreens
	Write-Host "$Screens"

})






# Dialog表示 (Dialogの[閉じる]ボタン押下まで帰ってこない)
[void]$SettingWnd.showDialog()

# 終了処理
exit 0
