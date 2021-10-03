$res_icon	= Join-Path "$PSScriptRoot" "\resource\picture.png"
$res_screen	= Join-Path "$PSScriptRoot" ".\20211002-213720.png"

$global:PictureWndXaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
		xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
		Title="��قǎB����Screenshot�摜��\��" x:Name="basewindow" WindowStyle="ThreeDBorderWindow" SnapsToDevicePixels="True" ResizeMode="CanResizeWithGrip"  FontFamily="UD Digi Kyokasho N-R" FontSize="18" Icon="$res_icon">
	<WindowChrome.WindowChrome>
		<WindowChrome GlassFrameThickness="0" ResizeBorderThickness="15" CornerRadius="0" CaptionHeight="0" UseAeroCaptionButtons="True"/>
	</WindowChrome.WindowChrome>
	<Window.TaskbarItemInfo>
		<TaskbarItemInfo x:Name="Displ1ayPicture" Overlay="$res_icon" Description="Screenshot�ŎB�����摜" />
	</Window.TaskbarItemInfo>


	<Image x:Name="image1" Source="$res_screen" Margin="0,0,0,0" Stretch="UniForm"/>

</Window>
"@

Import-Module -Name $PSScriptRoot\Set-SaveFolder.psm1
Add-Type -AssemblyName system.windows.forms
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.IO
Add-Type -AssemblyName System.Drawing

# ���ݒ�
Set-StrictMode -Version 3.0
$ErrorActionPreference = "stop"						# �G���[�����������ꍇ�̓X�N���v�g�̎��s���~
$PSDefaultParameterValues['out-file:width'] = 2000	# Script���s����1�s������2000�����ݒ�

# ���ʏ���������
scriptInitCommon

[xml]$xaml = $global:PictureWndXaml
$xamlReader = $xaml -as "System.Xml.XmlNodeReader"
$PictureWnd = [Windows.Markup.XamlReader]::Load( $xamlReader )
# Control element�� object���擾
$eleWnd = $PictureWnd.FindName( "basewindow" )
$elePic = $PictureWnd.FindName( "image1" )

# Event handler�o�^
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


# Dialog�\�� (Dialog��[����]�{�^�������܂ŋA���Ă��Ȃ�)
[void]$PictureWnd.showDialog()

# �I������
scriptEndCommon
exit 0
