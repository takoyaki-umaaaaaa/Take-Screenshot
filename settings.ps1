# 設定画面を起動
# 保存先フォルダを設定した場合、User環境変数に保持する
# (そのためregistryに内容が保持される)

# Requires -Version 5.0
Import-Module -Name $PSScriptRoot\Set-SaveFolder.psm1
Add-Type -AssemblyName system.windows.forms
Add-Type -AssemblyName PresentationFramework

# 環境設定
Set-StrictMode -Version 3.0
$ErrorActionPreference = "stop"						# エラーが発生した場合はスクリプトの実行を停止
$PSDefaultParameterValues['out-file:width'] = 2000	# Script実行中は1行あたり2000文字設定

# 共通初期化処理
scriptInitCommon

# 設定dialogを読み込み
Import-Module -Name $PSScriptRoot\SettingWindow.psm1
#[xml]$xaml = Get-Content ($PSScriptRoot + "\SettingWindow.xaml")
[xml]$xaml = $global:SettingDlgXaml
$xamlReader = $xaml -as "System.Xml.XmlNodeReader"
$SettingWnd = [Windows.Markup.XamlReader]::Load( $xamlReader )
# Window Loaded eventで Iconを変更
$SettingWnd.add_Loaded( {$SettingWnd.Icon = ($PSScriptRoot + "\resource\Setting.ico")} )


# Control elementの objectを取得
[int]$cnt = 0
foreach( $ctl in $global:Controls ){
	Write-Host "Element name ($($global:Controls[$cnt].Name))のobjectを探す"
	$global:Controls[$cnt].Element = $SettingWnd.FindName( $global:Controls[$cnt].Name )
	$cnt++
}

# Event handler登録
$btnSelectFolder_click = $global:Controls[3].Element.add_Click({askToSelectSaveFolder})	# 保存先指定Dialogを開くボタン
$btnDeleteEnvVal_click = $global:Controls[4].Element.add_Click({[Environment]::SetEnvironmentVariable( $global:ENV_SAVEFOLDER, $null, [System.EnvironmentVariableTarget]::User )})	# 環境変数を削除するボタン
$btnDeleteEnvVal_click = $global:Controls[8].Element.add_Click({$SettingWnd.Close()})	# [閉じる]ボタン

# Dialog表示 (Dialogの[閉じる]ボタン押下まで帰ってこない)
[void]$SettingWnd.showDialog()


# フォルダ選択ダイアログ表示
# [boolean]$ret = askToSelectSaveFolder

# 終了処理
scriptEndCommon
exit 0
