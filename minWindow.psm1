# 環境設定
Set-StrictMode -Version 3.0
$ErrorActionPreference = "stop"						# エラーが発生した場合はスクリプトの実行を停止

Add-Type -AssemblyName system.windows.forms
Add-Type -AssemblyName PresentationFramework

function dummyWindowXaml() {
return @"
	<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
			xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
			Title="ダミーウィンドウ" x:Name="basewindow" WindowStyle="None" SnapsToDevicePixels="True" ResizeMode="NoResize" 	Height="100" 	Width="100"	ShowInTaskbar = "False" FontFamily="UD Digi Kyokasho N-R" FontSize="18">
	<Grid Margin="0,0,0,0">
		<Label		x:Name="lbl1"	Content="abcdefあいうえお"	Margin=" 5,  5, 0,  0"	VerticalAlignment="Top"	 />
		<Button		x:Name="btn1"	Margin="  0, 20, 10,  0"	HorizontalAlignment="Right"	VerticalAlignment="Top"		Height="34" 	Width="54"		Background="White"		Cursor="Hand"	VerticalContentAlignment="Bottom" />
	</Grid>
	</Window>
"@
}

function displayDummyWindow([int] $hwnd) {
	Add-Type -TypeDefinition @"
	using System;
	using System.Runtime.InteropServices;
			[StructLayout(LayoutKind.Sequential)]
			public struct RECT {
				public int left;
				public int top;
				public int right;
				public int bottom;
			}
	namespace Win32 {
		public class aaa {
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
	[xml]$xaml = dummyWindowXaml
	[System.Xml.XmlNodeReader]$xamlReader = $xaml -as "System.Xml.XmlNodeReader"
	[object]$wndObj = [Windows.Markup.XamlReader]::Load( $xamlReader )
	
	# Control elementの objectを取得
	[object]$eleWnd = $wndObj.FindName( "basewindow" )
	[object]$eleBtn = $wndObj.FindName( "btn1" )
	
	$eleWnd.WindowState  = 'Maximized'
	$eleWnd.Left = 0
	$eleWnd.Top = 0

	$eleWnd.add_Loaded({
		$script:hwnd = (New-Object System.Windows.Interop.WindowInteropHelper($this)).Handle
		Write-Host "hwnd = $hwnd"
		[object]$rcWindow = New-Object RECT
		[Win32.aaa]::GetWindowRect($script:hwnd,[ref]$rcWindow)
		Write-Host "$($rcWindow.left) $($rcWindow.top) $($rcWindow.right) $($rcWindow.bottom)"
		$wi = $rcWindow.right - $rcWindow.left
		$he = $rcWindow.bottom - $rcWindow.top
		Write-Host "W=$wi H=$he"
	})

	$eleBtn.add_Click({ $eleWnd.Close() })
	$eleWnd.Add_MouseLeftButtonDown({ $eleWnd.DragMove() })
	$eleWnd.Add_MouseRightButtonDown({ $eleWnd.Close() })

	[object]$wih = New-Object System.Windows.Interop.WindowInteropHelper($wndObj)
	$wih.Owner = $hwnd;		# 親を設定
	$script:hwnd = $wih.EnsureHandle();	# Windowを表示せずに作成する

	Write-Host "`nhwndMin = $hwnd"
	[object]$rcWindow = New-Object RECT
	[Win32.aaa]::GetWindowRect($script:hwnd,[ref]$rcWindow)
	Write-Host "$($rcWindow.left) $($rcWindow.top) $($rcWindow.right) $($rcWindow.bottom)"
	$wi = [Math]::Abs($rcWindow.right) - [Math]::Abs($rcWindow.left)
	$he = [Math]::Abs($rcWindow.bottom) - [Math]::Abs($rcWindow.top)
	Write-Host "W=$wi H=$he"

	# Dialog表示 (Dialogの[閉じる]ボタン押下まで帰ってこない)
#	[void]$wndObj.showDialog()
}


