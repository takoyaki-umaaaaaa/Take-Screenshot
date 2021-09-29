




enum ScreenshotTarget {
	Primary		= 0
	Secondary	= 1
	# 2画面までサポート
}


# Screenshot を撮る
# 
function TakeScreenshot(
							[ScreenshotTarget]$targetDisplay = ([ScreenshotTarget]::Primary),
							[string]$destFilePath)
{
	begin {	# 1回だけやっておけばいいような処理を記載。For-Each objectで呼ばれると、ループ処理開始前に1回呼ばれる。
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
	}
}
