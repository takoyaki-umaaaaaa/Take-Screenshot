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

Import-Module -Name $PSScriptRoot\Set-SaveFolder.psm1
Import-Module -Name $PSScriptRoot\Take-Screenshot.psm1

# 環境設定
Set-StrictMode -Version 3.0
$ErrorActionPreference = "stop"						# エラーが発生した場合はスクリプトの実行を停止
$PSDefaultParameterValues['out-file:width'] = 2000	# Script実行中は1行あたり2000文字設定

# 共通初期化処理
scriptInitCommon

# Script title 出力
Write-Host -ForegroundColor Yellow "`n---- $global:SCRIPT_NAME   version $SCRIPT_VERSION ----"
Write-Host -ForegroundColor Yellow "日本語表示"

# [System.Windows.Forms.MessageBox]::Show("This is my msgbox")



# 保存先が未設定であれば、保存先フォルダ選択ダイアログで選択してもらう
if( [string]::IsNullOrEmpty($outputDirectory) ){
	[boolean]$result = checkUserEnvironmentValiableExists $ENV_SAVEFOLDER
	if( $result -eq $false ){
		[boolean]$ret = askToSelectSaveFolder
		if( $ret -eq $false ){
			exit 0
		}
		[string]$outputDirectory = [Environment]::GetEnvironmentVariable( $ENV_SAVEFOLDER, [System.EnvironmentVariableTarget]::User )
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
TakeScreenshot $targetDisplayNumber $destFilePath

#終了処理
scriptEndCommon
exit 0
