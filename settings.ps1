# 設定画面を起動
# 保存先フォルダを設定した場合、User環境変数に保持する
# (そのためregistryに内容が保持される)

# Requires -Version 5.0
Import-Module -Name $PSScriptRoot\Set-SaveFolder.psm1
Add-Type -AssemblyName system.windows.forms

# 環境設定
Set-StrictMode -Version 3.0
$ErrorActionPreference = "stop"						# エラーが発生した場合はスクリプトの実行を停止
$PSDefaultParameterValues['out-file:width'] = 2000	# Script実行中は1行あたり2000文字設定

# 共通初期化処理
scriptInitCommon

# フォルダ選択ダイアログ表示
[boolean]$ret = askToSelectSaveFolder

# 終了処理
scriptEndCommon
exit 0
