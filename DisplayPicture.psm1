# 環境設定
Set-StrictMode -Version 3.0
$ErrorActionPreference = "stop"						# エラーが発生した場合はスクリプトの実行を停止
$PSDefaultParameterValues['out-file:width'] = 2000	# Script実行中は1行あたり2000文字設定

[string]$res_icon		= Join-Path "$PSScriptRoot" ".\resource\Gear.png"
[string]$res_background	= Join-Path "$PSScriptRoot" ".\resource\Gear2.png"
[string]$res_picicon	= Join-Path "$PSScriptRoot" ".\resource\picture.png"
[string]$ctrlPicture	= ""



function GetDisplayScaling([IntPtr]$hParentWnd) {
	Write-Host "`nGetDisplayScaling"
	Import-Module -Name $PSScriptRoot\dummyWindow.psm1
	Add-Type -TypeDefinition @"
	using System.Runtime.InteropServices;
	[StructLayout(LayoutKind.Sequential)]
	public struct RECT {
		public int left;
		public int top;
		public int right;
		public int bottom;
	}
"@

	# Low DPI window と High DPI window を maximizeで作成し、
	# 取得した座標値から Display scalingを出す。
	
	# Low DPI window
	[IntPtr]$script:DpiOldSetting = SetThreadDpiAwarenessContext(-1)
	[RECT]$rectLowDpi = displayDummyWindow $hParentWnd

	# High DPI window
	[IntPtr]$script:DpiOldSetting = SetThreadDpiAwarenessContext(-4)
	[Rect]$rectHighDpi = displayDummyWindow $hParentWnd

	SetThreadDpiAwarenessContext($script:DpiOldSetting)

}


function GetPictureWndXaml() {
	return @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
		xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
		Title="先ほど撮ったScreenshot画像を表示" x:Name="basewindow" WindowStyle="ThreeDBorderWindow" Background="Black" SnapsToDevicePixels="True" ResizeMode="CanResizeWithGrip" ShowInTaskbar = "True" FontFamily="UD Digi Kyokasho N-R" FontSize="18" Icon="$res_icon">
	<WindowChrome.WindowChrome>
		<WindowChrome GlassFrameThickness="0" ResizeBorderThickness="10" CornerRadius="0" CaptionHeight="0" UseAeroCaptionButtons="True"/>
	</WindowChrome.WindowChrome>
	<Window.TaskbarItemInfo>
		<TaskbarItemInfo x:Name="Displ1ayPicture" Overlay="$res_picicon" Description="Screenshotで撮った画像" />
	</Window.TaskbarItemInfo>

	<Canvas		x:Name="canvas1" Margin="10,10,10,10">
		<Image	x:Name="image1"												Canvas.Top="0"		Canvas.Left="0"  Source="$ctrlPicture" Stretch="UniForm"/>
		<Viewbox	x:Name="viwFolder"	Canvas.Bottom="20"	Canvas.Left="20"	Stretch="Fill">
			<Button	x:Name="btnFolder"	Content="保存先の&#xD;&#xA;📁を開く"	Background="White"		Cursor="Hand"	VerticalContentAlignment="Center"  Opacity="0.3" FontSize="75"  />
		</Viewbox>
		<Viewbox	x:Name="viwClose"	Canvas.Bottom="20"	Canvas.Right="20"	Stretch="Fill">
			<Button	x:Name="btnClose"	Content="閉じる"						Background="White"		Cursor="Hand"	VerticalContentAlignment="Center"  Opacity="0.3" FontSize="16"  />
		</Viewbox>
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
	$script:DpiAwareness = SetThreadDpiAwarenessContext(-1)

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
	[object]$eleViwFolder	= $PictureWnd.FindName( "viwFolder" )
	[object]$eleViwClose	= $PictureWnd.FindName( "viwClose" )

	# Event handler登録
#	$eleWnd.Add_MouseLeftButtonDown({ param($sender, $e); $e | Get-Member | Write-Host; $eleWnd.DragMove(); })
	$eleWnd.Add_MouseLeftButtonDown({ $eleWnd.DragMove() })
	$eleWnd.Add_MouseRightButtonDown({ $PictureWnd.Close() })

	$eleWnd.Add_Loaded({
		try {
			Write-Host "Window Loaded"
			$fileInfo = [System.Drawing.Image]::FromFile($picFilePath)

			[double]$scale = GetDisplayScaleValue
			[double]$size = 0.1		# 画像を一割縮小して中央寄せで表示する

			# ウィンドウを画像のアスペクト比に合わせたサイズに変更して表示
			$eleWnd.Left	= $fileInfo.Width  * $size / 2 / $scale
			$eleWnd.Top		= $fileInfo.Height * $size / 2 / $scale
			$eleWnd.Width	= $fileInfo.Width  * (1 - $size) / $scale
			$eleWnd.Height	= $fileInfo.Height * (1 - $size) / $scale
			Write-Host "eleWnd = W=$($eleWnd.Width), H=$($eleWnd.Height)"
			Write-Host "$fileInfo.Width * $size / 2 / $scale"
		}
		catch {
			$Error[0] | Select-Object -Property * | Write-Host
		}
	})

	$eleCanvas.Add_SizeChanged({
		# Controlの再配置。
		# 画像は Canvasと同じ大きさ。
		$elePic.Width = $eleCanvas.ActualWidth; $elePic.Height = $eleCanvas.ActualHeight;

		# 📁を開くボタン
		# ViewBoxは Canvas上では自動で拡大縮小しないっぽいが、手動で変えれば内容は自動で変えてくれる
		# ただ、Font sizeを計算するわけではなく、画像として大きさの変更をするだけっぽい・・・？
		[System.Windows.Controls.Canvas]::setLeft(		$eleViwFolder, $eleCanvas.ActualWidth	* 5 / 100 )
		[System.Windows.Controls.Canvas]::setBottom(	$eleViwFolder, $eleCanvas.ActualWidth	* 5 / 100 )
		$eleViwFolder.Width		= ($eleCanvas.ActualWidth	* 32 / 100 )
		$eleViwFolder.Height	= ($eleCanvas.ActualHeight	* 25 / 100)

		# 閉じるボタン
		[System.Windows.Controls.Canvas]::setRight(		$eleViwClose, $eleCanvas.ActualWidth	* 5 / 100 )
		[System.Windows.Controls.Canvas]::setBottom(	$eleViwClose, $eleCanvas.ActualWidth	* 5 / 100 )
		$eleViwClose.Width		= ($eleCanvas.ActualWidth	* 32 / 100 )
		$eleViwClose.Height		= ($eleCanvas.ActualHeight	* 25 / 100)
	})

	# Dialog表示 (Dialogの[閉じる]ボタン押下まで帰ってこない)
	Write-Host "showDialog"
	[void]$PictureWnd.showDialog()
}
