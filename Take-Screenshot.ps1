param(
		[Parameter( ValueFromPipeline = $true )]
		[int]$targetDisplayNumber = 0,

		[Parameter()][AllowEmptyString()]
		[string]$outputDirectory,

		[Parameter()][AllowEmptyString()]
		[string]$outputFileName
)
if( [string]::IsNullOrEmpty($outputDirectory) ){
	$outputDirectory = $PSScriptRoot
}

# Scriptそのものに対する定数定義
New-Variable  -Name SCRIPT_NAME		-Value "Take-Screenshot"	-Option Constant  -Scope Script
New-Variable  -Name SCRIPT_VERSION	-Value 0.8.0				-Option Constant  -Scope Script

# Script title 出力
Write-Host -ForegroundColor Yellow "`n---- $SCRIPT_NAME   version $SCRIPT_VERSION ----"



enum ScreenshotTarget {
	Primary		= 0
	Secondary	= 1
	# 2画面までサポート
}


function Take-Screenshot(
							[ScreenshotTarget]$targetDisplay = ([ScreenshotTarget]::Primary),
							[string]$destPath = $PSScriptRoot,
							[string]$fileName)
{
	begin {	# 1回だけやっておけばいいような処理を記載。For-Each objectで呼ばれると、ループ処理開始前に1回呼ばれる。

		# 引数チェック
		if( -not (Test-Path -Path $destPath -PathType Container) ){Write-Host -ForegroundColor Red "`n保存先のフォルダ($destPath)が見つかりません。正しいフォルダ名を指定してください。"; exit -1}
		if( [string]::IsNullOrEmpty($fileName) ){
			# ファイル名が未指定の場合は「年月日-時分秒」をファイル名とする
			$fileName = Get-Date -Format yyyyMMdd-HHmmss
			$fileName = $fileName + ".png"
		}
		[string]$destFilePath = Join-Path $destPath $fileName
		if( Test-Path -Path $destFilePath -PathType Leaf ){
			$Ans = Read-Host "`n指定のファイルは既に存在しています。`n上書きしてもよろしいですか？(Y/N)"
			if( $Ans -ne "Y" ){Write-Host "`n別ファイル名を指定してください"; exit 0}
		}


		Add-Type -AssemblyName System.Windows.Forms

		# Win32apiをimport
		Add-Type -MemberDefinition @"
		[DllImport("user32.dll", SetLastError=true)]
		public static extern short SetThreadDpiAwarenessContext(short dpiContext);
"@		-Namespace Win32 -Name NativeMethods

		# 高DPI対応済み設定に変更(PowerShell標準設定では画面座標取得時に画面拡大率分だけ小さい値を返されるので)
		[int]$DpiOldSetting = [Win32.NativeMethods]::SetThreadDpiAwarenessContext(-3)

		Write-Host ""
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

		if( $targetDisplay -eq [ScreenshotTarget]::Primary ){
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
		# 高Dpi対応設定を元に戻す
		[void][Win32.NativeMethods]::SetThreadDpiAwarenessContext($DpiOldSetting)
	}
}


Take-Screenshot $targetDisplayNumber $outputDirectory $outputFileName

exit 0
