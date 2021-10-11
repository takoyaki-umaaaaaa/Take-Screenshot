# 環境設定
Set-StrictMode -Version 3.0
$ErrorActionPreference = "stop"						# エラーが発生した場合はスクリプトの実行を停止
$PSDefaultParameterValues['out-file:width'] = 2000	# Script実行中は1行あたり2000文字設定

[string]$res_icon		= Join-Path "$PSScriptRoot" ".\resource\Gear.png"
[string]$res_background	= Join-Path "$PSScriptRoot" ".\resource\Gear2.png"
[string]$res_picicon	= Join-Path "$PSScriptRoot" ".\resource\picture.png"
[string]$ctrlPicture	= ""




function GetPictureWndXaml() {
	return @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
		xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
		Title="先ほど撮ったScreenshot画像を表示" x:Name="basewindow" WindowStyle="ThreeDBorderWindow" Background="Black" SnapsToDevicePixels="True" ResizeMode="CanResizeWithGrip" ShowInTaskbar = "True" FontFamily="游明朝" FontSize="18" Icon="$res_icon">
	<WindowChrome.WindowChrome>
		<WindowChrome GlassFrameThickness="0" ResizeBorderThickness="10" CornerRadius="0" CaptionHeight="0" UseAeroCaptionButtons="True"/>
	</WindowChrome.WindowChrome>
	<Window.TaskbarItemInfo>
		<TaskbarItemInfo x:Name="Displ1ayPicture" Overlay="$res_picicon" Description="Screenshotで撮った画像" />
	</Window.TaskbarItemInfo>

	<Canvas		x:Name="canvas1" Margin="10,10,10,10">
		<Image	x:Name="image1"														Canvas.Top="0"		Canvas.Left="0"  Source="$ctrlPicture" Stretch="UniForm"/>
		<Button	x:Name="btnFolder"	Content=" 保存先&#xD;&#xA;📁を開く"			Canvas.Bottom="20"	Canvas.Left="20"	Background="White"		Cursor="Hand"	Opacity="0.3" FontSize="60"  />
		<Button	x:Name="btnClose"	Content="閉じる"									Canvas.Bottom="20"	Canvas.Right="20"	Background="White"		Cursor="Hand"	Opacity="0.3" FontSize="60"  />
	</Canvas>
</Window>
"@
}

function ShowPicture([string]$picFilePath) {
	Write-Host "`n---------- DisplayPicture.psm1 -- ShowPicture ------------------------------------------"
	Add-Type -AssemblyName system.Windows.forms
	Add-Type -AssemblyName PresentationFramework
	Add-Type -AssemblyName System.IO
	Add-Type -AssemblyName System.Drawing

	# 少しだけ今どきの Control表示にする
	Add-Type -AssemblyName system.windows.forms
	[System.Windows.Forms.Application]::EnableVisualStyles()
	[System.Windows.Forms.Application]::VisualStyleState = 3

	# Window作成前に呼ぶことで、これ以降にこのScriptで作られる
	# Top Level windowが High DPI対応として動作する
	$script:DpiAwareness = SetThreadDpiAwarenessContext(-4)

	# Controlの再配置処理。Loaded直後にも呼びたいので変数に入れて使いまわす。
	$func_relocateControls = {
		# Picture controlは Canvasと同じ大きさ。
		$elePic.Width = $eleCanvas.ActualWidth; $elePic.Height = $eleCanvas.ActualHeight;

		# 📁を開くボタン
		[System.Windows.Controls.Canvas]::setLeft(		$eleBtnFolder, $eleCanvas.ActualWidth	* 5 / 100 )
		[System.Windows.Controls.Canvas]::setBottom(	$eleBtnFolder, $eleCanvas.ActualWidth	* 5 / 100 )
		$eleBtnFolder.Width		= ($eleCanvas.ActualWidth	* 18 / 100 )
		$eleBtnFolder.Height	= ($eleCanvas.ActualHeight	* 13 / 100 )

		# 閉じるボタン
		[System.Windows.Controls.Canvas]::setRight(		$eleBtnClose, $eleCanvas.ActualWidth	* 5 / 100 )
		[System.Windows.Controls.Canvas]::setBottom(	$eleBtnClose, $eleCanvas.ActualWidth	* 5 / 100 )
		$eleBtnClose.Width		= ($eleCanvas.ActualWidth	* 18 / 100 )
		$eleBtnClose.Height		= ($eleCanvas.ActualHeight	* 13 / 100 )

		# ボタンの Font size変更
		# 幅:362, 高さ:200 のとき、Font size:55 がいい感じ
		[double]$ratio_w = $eleBtnFolder.ActualWidth  / 362
		[double]$ratio_h = $eleBtnFolder.ActualHeight / 200
		[double]$ratio_font = [Math]::Min($ratio_w, $ratio_h) * 55
		$eleBtnFolder.fontSize	= $ratio_font
		$eleBtnClose.fontSize	= $ratio_font
	}


	# 画像の "src=" を設定
	$ctrlPicture = $picFilePath

	[xml]$xaml = GetPictureWndXaml
	[System.Xml.XmlNodeReader]$xamlReader = $xaml -as "System.Xml.XmlNodeReader"
	[object]$PictureWnd = [Windows.Markup.XamlReader]::Load( $xamlReader )
	# Control elementの objectを取得
	[object]$eleWnd			= $PictureWnd.FindName( "basewindow" )
	[object]$eleCanvas		= $PictureWnd.FindName( "canvas1" )
	[object]$elePic			= $PictureWnd.FindName( "image1" )
	[object]$eleBtnFolder	= $PictureWnd.FindName( "btnFolder" )
	[object]$eleBtnClose	= $PictureWnd.FindName( "btnClose" )

	# Event handler登録
#	$eleWnd.Add_MouseLeftButtonDown({ param($sender, $e); $e | Get-Member | Write-Host; $eleWnd.DragMove(); })
	$eleWnd.Add_MouseLeftButtonDown({ $eleWnd.DragMove() })
	$eleWnd.Add_MouseRightButtonDown({ $PictureWnd.Close() })
	$eleWnd.Add_Loaded({
		try {
			Write-Host "Window Loaded"
			$script:hwndPic = (New-Object System.Windows.Interop.WindowInteropHelper($this)).Handle
			$fileInfo = [System.Drawing.Image]::FromFile($picFilePath)
			Write-Host "$script:hwndPic = $($script:hwndPic)"

			[double]$scale = GetDisplayScaleValue
			[double]$size = 0.1		# 画像を一割縮小して中央寄せで表示する

			# ウィンドウを画像のアスペクト比に合わせたサイズに変更して表示
			$eleWnd.Left	= $fileInfo.Width  * $size / 2 / $scale
			$eleWnd.Top		= $fileInfo.Height * $size / 2 / $scale
			$eleWnd.Width	= $fileInfo.Width  * (1 - $size) / $scale
			$eleWnd.Height	= $fileInfo.Height * (1 - $size) / $scale
			Write-Host "eleWnd = W=$($eleWnd.Width), H=$($eleWnd.Height)"
			Write-Host "$fileInfo.Width * $size / 2 / $scale"

			&$func_relocateControls
		}
		catch {
			$Error[0] | Select-Object -Property * | Write-Host
		}
	})
	$eleWnd.Add_MouseMove({
		param($sender, $e)
		$pt = $e.GetPosition($this)

		# Windowの対角線を距離の基準にする。ある程度近づいてから表示したいので、適当に÷8
		$distwnd = ($eleWnd.ActualWidth * $eleWnd.ActualWidth + $eleWnd.ActualHeight * $eleWnd.ActualHeight) / 8

		# カーソルと対象ボタンの距離計算(📁を開くボタン)
		$btnCenter = New-Object System.Drawing.Point(0, 0)
		$btnCenter.x = 							  [System.Windows.Controls.Canvas]::getLeft($eleBtnFolder)    + $eleBtnFolder.ActualWidth  / 2
		$btnCenter.y = ($eleCanvas.ActualHeight - [System.Windows.Controls.Canvas]::getBottom($eleBtnFolder)) - $eleBtnFolder.ActualHeight / 2

		# カーソル☜☞ボタン間の距離を測り、透明度を設定(📁を開くボタン)
		$distanceCurrent = calcDistance $pt $btnCenter
		$Opacity = $distanceCurrent / $distwnd			# Windowの対角線基準で透明度を出す
		if( $Opacity -le 1 ){ $eleBtnFolder.Opacity = 1 - $Opacity }
		else				{ $eleBtnFolder.Opacity = 0 }


		# カーソルと対象ボタンの距離計算(閉じるボタン)
		$btnCenter.x = ($eleCanvas.ActualWidth  - [System.Windows.Controls.Canvas]::getRight($eleBtnClose))  - $eleBtnClose.ActualWidth  / 2
		$btnCenter.y = ($eleCanvas.ActualHeight - [System.Windows.Controls.Canvas]::getBottom($eleBtnClose)) - $eleBtnClose.ActualHeight / 2

		# カーソル☜☞ボタン間の距離を測り、透明度を設定(閉じるボタン)
		$distanceCurrent = calcDistance $pt $btnCenter
		$Opacity = $distanceCurrent / $distwnd			# Windowの対角線基準で透明度を出す
		if( $Opacity -le 1 ){ $eleBtnClose.Opacity = 1 - $Opacity }
		else				{ $eleBtnClose.Opacity = 0 }
	})
	$eleWnd.Add_MouseLeave({ $eleBtnFolder.Opacity = 0; $eleBtnClose.Opacity = 0 })
	$eleCanvas.Add_SizeChanged( $func_relocateControls )
	$eleBtnFolder.Add_Click({ $folder = Split-Path $picFilePath -Parent; Invoke-Item ([IO.FileInfo]$folder) })
	$eleBtnClose.Add_Click({ $PictureWnd.Close() })


	# Dialog表示 (Dialogの[閉じる]ボタン押下まで帰ってこない)
	Write-Host "showDialog"
	[void]$PictureWnd.showDialog()
}
