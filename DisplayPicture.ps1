$res_icon	= Join-Path "$PSScriptRoot" "\resource\picture.png"
$res_screen	= Join-Path "$PSScriptRoot" ".\20211002-213720.png"

$global:PictureWndXaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
		xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
		Title="先ほど撮ったScreenshot画像を表示" x:Name="basewindow" WindowStyle="ThreeDBorderWindow" SnapsToDevicePixels="True" ResizeMode="CanResizeWithGrip"  FontFamily="UD Digi Kyokasho N-R" FontSize="18" Icon="$res_icon">
	<WindowChrome.WindowChrome>
		<WindowChrome GlassFrameThickness="0" ResizeBorderThickness="15" CornerRadius="0" CaptionHeight="0" UseAeroCaptionButtons="True"/>
	</WindowChrome.WindowChrome>
	<Window.TaskbarItemInfo>
		<TaskbarItemInfo x:Name="Displ1ayPicture" Overlay="$res_icon" Description="Screenshotで撮った画像" />
	</Window.TaskbarItemInfo>


	<Image x:Name="image1" Source="$res_screen" Margin="0,0,0,0" Stretch="UniForm"/>

</Window>
"@

Import-Module -Name $PSScriptRoot\Set-SaveFolder.psm1
Add-Type -AssemblyName system.windows.forms
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.IO
Add-Type -AssemblyName System.Drawing

# 環境設定
Set-StrictMode -Version 3.0
$ErrorActionPreference = "stop"						# エラーが発生した場合はスクリプトの実行を停止
$PSDefaultParameterValues['out-file:width'] = 2000	# Script実行中は1行あたり2000文字設定

# 共通初期化処理
scriptInitCommon

[xml]$xaml = $global:PictureWndXaml
$xamlReader = $xaml -as "System.Xml.XmlNodeReader"
$PictureWnd = [Windows.Markup.XamlReader]::Load( $xamlReader )
# Control elementの objectを取得
$eleWnd = $PictureWnd.FindName( "basewindow" )
$elePic = $PictureWnd.FindName( "image1" )

# Event handler登録
# $elePic.add_Click({$PictureWnd.Close()})
$eleWnd.Add_MouseLeftButtonDown({ $eleWnd.DragMove() })
$eleWnd.Add_Loaded({
	Write-Host "Loaded"
	$fileInfo = [System.Drawing.Image]::FromFile($res_screen)

	$eleWnd.Left = 10
	$eleWnd.Top = 10
	$eleWnd.Width = (0 + $fileInfo.Width + 0) / 3
	$eleWnd.Height = (0 + $fileInfo.Height + 0) /3

	Write-Host "Width  = $($eleWnd.Width)"
	Write-Host "Height = $($eleWnd.Height)"
	$baa = [System.Windows.SystemParameters]::WorkArea.Width
	$bab = [System.Windows.SystemParameters]::WorkArea.Height
	Write-Host "workWidth  = $baa"
	Write-Host "workHeight = $bab"
	$ccc = [System.Windows.SystemParameters]::VirtualScreenWidth
	$ccd = [System.Windows.SystemParameters]::VirtualScreenHeight 
	Write-Host "workWidth  = $ccc"
	Write-Host "workHeight = $ccd"
	$ddd = [System.Windows.SystemParameters]::FullPrimaryScreenWidthKey  
	Write-Host "Dpi = $ddd"
	$eee = [System.Windows.Forms.AutoScaleMode]::Dpi
	Write-Host "Dpi = $eee"
	
	
	conv-ver
})

[object]$Screens = [System.Windows.Forms.Screen]::AllScreens
$screens


# Dialog表示 (Dialogの[閉じる]ボタン押下まで帰ってこない)
[void]$PictureWnd.showDialog()

# 終了処理
scriptEndCommon
exit 0
