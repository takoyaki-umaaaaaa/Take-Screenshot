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


	<Image x:Name="image1" Source="$ctrlPicture" Margin="10,10,10,10" Stretch="UniForm"/>

</Window>
"@
}

function ShowPicture([string]$picFilePath) {
	Write-Host "`n---------- DisplayPicture.psm1 -- ShowPicture ------------------------------------------"
	Add-Type -AssemblyName system.windows.forms
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
	[object]$eleWnd = $PictureWnd.FindName( "basewindow" )
	[object]$elePic = $PictureWnd.FindName( "image1" )

	# Event handler登録
	# $elePic.add_Click({$PictureWnd.Close()})
	$eleWnd.Add_MouseLeftButtonDown({ $eleWnd.DragMove() })
	$eleWnd.Add_MouseRightButtonDown({ $PictureWnd.Close() })

	$eleWnd.Add_Loaded({
		try {
			Write-Host "Window Loaded"
			$fileInfo = [System.Drawing.Image]::FromFile($picFilePath)

			Write-Host "Window Loaded"
			[double]$scale = GetDisplayScaleValue
			Write-Host "Window Loaded"
			[double]$size = 0.1		# 画像を一割縮小して中央寄せで表示する
			Write-Host "Window Loaded"

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

	# Dialog表示 (Dialogの[閉じる]ボタン押下まで帰ってこない)
	Write-Host "showDialog"
	[void]$PictureWnd.showDialog()
}
