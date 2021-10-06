# 環境設定
Set-StrictMode -Version 3.0
$ErrorActionPreference = "stop"						# エラーが発生した場合はスクリプトの実行を停止
$PSDefaultParameterValues['out-file:width'] = 2000	# Script実行中は1行あたり2000文字設定


[string]$res_icon		= Join-Path "$PSScriptRoot" ".\resource\Gear.png"
[string]$res_background	= Join-Path "$PSScriptRoot" ".\resource\Gear2.png"
[string]$res_picicon	= Join-Path "$PSScriptRoot" ".\resource\picture.png"
[string]$res_screen		= Join-Path "$PSScriptRoot" ".\20211003-224633.png"

$global:PictureWndXaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
		xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
		Title="先ほど撮ったScreenshot画像を表示" x:Name="basewindow" WindowStyle="ThreeDBorderWindow" SnapsToDevicePixels="True" ResizeMode="CanResizeWithGrip" ShowInTaskbar = "True" FontFamily="UD Digi Kyokasho N-R" FontSize="18" Icon="$res_icon">
	<WindowChrome.WindowChrome>
		<WindowChrome GlassFrameThickness="0" ResizeBorderThickness="10" CornerRadius="0" CaptionHeight="0" UseAeroCaptionButtons="True"/>
	</WindowChrome.WindowChrome>
	<Window.TaskbarItemInfo>
		<TaskbarItemInfo x:Name="Displ1ayPicture" Overlay="$res_picicon" Description="Screenshotで撮った画像" />
	</Window.TaskbarItemInfo>


	<Image x:Name="image1" Source="$res_screen" Margin="0,0,0,0" Stretch="UniForm"/>

</Window>
"@

Import-Module -Name $PSScriptRoot\Set-SaveFolder.psm1
Add-Type -AssemblyName system.windows.forms
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.IO
Add-Type -AssemblyName System.Drawing
Write-Host "TypeDefinition"
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

		[StructLayout(LayoutKind.Sequential)]
		public struct POINTSTRUCT { 
			public int x;
			public int y;
			public POINTSTRUCT(int x, int y) {
			  this.x = x; 
			  this.y = y;
			} 
		} 
		[StructLayout(LayoutKind.Sequential)]
		public struct RECT {
			public int left;
			public int top;
			public int right;
			public int bottom;
		}
		[StructLayout(LayoutKind.Sequential,CharSet=CharSet.Auto, Pack=4)]
		public class MONITORINFO {
			public int	cbSize		= Marshal.SizeOf(typeof(MONITORINFO));
			public RECT	rcMonitor	= new RECT(); 
			public RECT	rcWork		= new RECT(); 
			public int	dwFlags		= 0;
		}
		[StructLayout(LayoutKind.Sequential,CharSet=CharSet.Auto, Pack=4)]
		public class MONITORINFOEX { 
			public int	cbSize		= Marshal.SizeOf(typeof(MONITORINFOEX));
			public RECT	rcMonitor	= new RECT(); 
			public RECT	rcWork		= new RECT(); 
			public int	dwFlags		= 0;
			[MarshalAs(UnmanagedType.ByValArray, SizeConst=32)] 
			public char[]  szDevice	= new char[32];
		}

namespace Win32 {
	public class NativeDPIs {
		[DllImport("user32.dll", SetLastError=true)]
		public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);
		[DllImport("user32.dll", SetLastError=true)]
		public static extern IntPtr FindWindow(string lpClassName, IntPtr lpWindowName);
		[DllImport("user32.dll", SetLastError=true)]
		public static extern IntPtr FindWindow(IntPtr lpClassName, string lpWindowName);

		[DllImport("user32.dll", SetLastError=true)]
		public static extern IntPtr MonitorFromWindow(IntPtr hwnd, UInt32 dwFlags);
		[DllImport("User32.dll", SetLastError=true)]
		public static extern IntPtr MonitorFromPoint(POINTSTRUCT pt, int flags);

		[DllImport("user32.dll", SetLastError=true)]
		[return: MarshalAs(UnmanagedType.Bool)]
		public static extern bool GetMonitorInfo(IntPtr hMonitor,  [In, Out] MONITORINFOEX lpmk);

		[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
	    [DllImport("user32.dll")] public static extern int SetForegroundWindow(IntPtr hwnd);

		[DllImport("user32.dll")]
		[return: MarshalAs(UnmanagedType.Bool)]
		public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
		[DllImport("user32.dll")]
		[return: MarshalAs(UnmanagedType.Bool)]
		public static extern bool GetClientRect(IntPtr hWnd, out RECT lpRect);
		[DllImport("user32.dll")]
		[return: MarshalAs(UnmanagedType.Bool)]
		public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);
	}
}
"@
Write-Host "MemberDefinition end"

# 共通初期化処理
scriptInitCommon


[xml]$xaml = $global:PictureWndXaml
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
	Write-Host "Loaded"
	$fileInfo = [System.Drawing.Image]::FromFile($res_screen)

	$eleWnd.Left = 10
	$eleWnd.Top = 10
	$eleWnd.Width = (0 + $fileInfo.Width + 0) / 3
	$eleWnd.Height = (0 + $fileInfo.Height + 0) /3

	Write-Host "Width  = $($eleWnd.Width)"
	Write-Host "Height = $($eleWnd.Height)"
	[int]$baa = [System.Windows.SystemParameters]::WorkArea.Width
	[int]$bab = [System.Windows.SystemParameters]::WorkArea.Height
	Write-Host "workWidth  = $baa"
	Write-Host "workHeight = $bab"
	[int]$ccc = [System.Windows.SystemParameters]::VirtualScreenWidth
	[int]$ccd = [System.Windows.SystemParameters]::VirtualScreenHeight 
	Write-Host "workWidth  = $ccc"
	Write-Host "workHeight = $ccd"
	[int]$ddd = [System.Windows.SystemParameters]::FullPrimaryScreenWidth  
	Write-Host "primaryWidth = $ddd"
	
	Write-Host "call"
	Add-Type -AssemblyName System.Drawing

	Write-Host "findwindow"
	[IntPtr]$hWnd = [Win32.NativeDPIs]::FindWindow( [IntPtr]::Zero, "先ほど撮ったScreenshot画像を表示")
	Write-Host "HWND = $hWnd"
	[IntPtr]$hMonitor = [Win32.NativeDPIs]::MonitorFromWindow( $hWnd, 2 )
	Write-Host "HMONITOR = $hMonitor"

	[MONITORINFOEX]$info = New-Object MONITORINFOEX

	Write-Host "GetMonitorInfo"
	[boolean]$ret = GetMonitorInfo($hMonitor, [ref]$info);
	Write-Host "GetMonitorInfo $ret"

	
	Write-Host "Loaded end"
})

[object]$Screens = [System.Windows.Forms.Screen]::AllScreens
$screens


# Dialog表示 (Dialogの[閉じる]ボタン押下まで帰ってこない)
Write-Host "showDialog"
[void]$PictureWnd.showDialog()

# 終了処理
scriptEndCommon
exit 0
