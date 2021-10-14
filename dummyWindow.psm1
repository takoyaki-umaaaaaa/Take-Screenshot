# 環境設定
Set-StrictMode -Version 3.0
$ErrorActionPreference = "stop"						# エラーが発生した場合はスクリプトの実行を停止

. $PSScriptRoot\Utilities.ps1	# 型の定義があるため、同じスコープに関数を取り込む
Add-Type -AssemblyName system.windows.forms
Add-Type -AssemblyName PresentationFramework

# 使用するWin32 APIを定義
DefineWin32API


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

# $resolution, $workareaは System.Draw.Point型。幅高さを返す
function displayDummyWindow([IntPtr]$hParentwnd=[IntPtr]::Zero, [ref]$resolution, [ref]$workarea, [boolean]$display=$false) {
	[xml]$xaml = dummyWindowXaml
	[System.Xml.XmlNodeReader]$xamlReader = $xaml -as "System.Xml.XmlNodeReader"
	[object]$wndObj = [Windows.Markup.XamlReader]::Load( $xamlReader )

	# Control elementの objectを取得
	[object]$eleWnd = $wndObj.FindName( "basewindow" )
	[object]$eleBtn = $wndObj.FindName( "btn1" )
	
	$eleWnd.WindowState  = 'Maximized'
	
	$eleWnd.add_Loaded({
		$script:hwnd = (New-Object System.Windows.Interop.WindowInteropHelper($this)).Handle
		Write-Host "hwnd = $hwnd"
		[object]$rcWindow = New-Object RECT
		[Win32.NativeAPIs]::GetClientRect($script:hwnd,[ref]$rcWindow)
		Write-Host "$($rcWindow.left) $($rcWindow.top) $($rcWindow.right) $($rcWindow.bottom)"

		$UserName				= [Windows.Forms.SystemInformation]::UserName;				Write-Host "UserName        $UserName"
		$MonitorCount			= [Windows.Forms.SystemInformation]::MonitorCount;			Write-Host "MonitorCount    $MonitorCount"
		$PrimaryMonitorMaximizedWindowSize = [Windows.Forms.SystemInformation]::PrimaryMonitorMaximizedWindowSize;	Write-Host "PrimaryMonitorMaximizedWindowSize   $PrimaryMonitorMaximizedWindowSize   "
		$PrimaryMonitorSize		= [Windows.Forms.SystemInformation]::PrimaryMonitorSize;	Write-Host "PrimaryMonitorSize   $PrimaryMonitorSize"
		$VirtualScreen			= [Windows.Forms.SystemInformation]::VirtualScreen;			Write-Host "VirtualScreen   $VirtualScreen"
		$WorkingArea			= [Windows.Forms.SystemInformation]::WorkingArea;			Write-Host "WorkingArea     $WorkingArea"

		# 呼び出し元に画面解像度を返す
		if( $null -ne $resolution ){
			$resolution.Value.x	= [Math]::Abs($rcWindow.right) - [Math]::Abs($rcWindow.left);
			$resolution.Value.y	= [Math]::Abs($rcWindow.bottom) - [Math]::Abs($rcWindow.top);
			Write-Host "**** return value W=$($resolution.Value.x) H=$($resolution.Value.y) ****"
		}
	})

	$eleBtn.add_Click({ $eleWnd.Close() })
	$eleWnd.Add_MouseLeftButtonDown({ $eleWnd.DragMove() })
	$eleWnd.Add_MouseRightButtonDown({ $eleWnd.Close() })

	[object]$wih = New-Object System.Windows.Interop.WindowInteropHelper($wndObj)
	if( 0 -ne $hParentwnd ){	$wih.Owner = $hParentwnd	}
	else {						$wih.Owner = [IntPtr]::Zero	}

	if( $display ){
		# Dialog表示 (Dialogの[閉じる]ボタン押下まで帰ってこない)
		[void]$wndObj.showDialog()

		if( $null -ne $resolution ){
			Write-Host "W=$($resolution) H=$($resolution)"
		}
	}
	else {
		$script:hwnd = $wih.EnsureHandle();	# Windowを表示せずに作成する

		Write-Host "`n---------- dummyWindow.psm1 --------------------------------------------"
		Write-Host "`nhwndDummy = $hwnd"
		[object]$rcWindow = New-Object RECT
		[Win32.NativeAPIs]::GetWindowRect($script:hwnd,[ref]$rcWindow)
		Write-Host "$($rcWindow.left) $($rcWindow.top) $($rcWindow.right) $($rcWindow.bottom)"

		$UserName				= [Windows.Forms.SystemInformation]::UserName;				Write-Host "UserName        $UserName"
		$MonitorCount			= [Windows.Forms.SystemInformation]::MonitorCount;			Write-Host "MonitorCount    $MonitorCount"
		$PrimaryMonitorMaximizedWindowSize = [Windows.Forms.SystemInformation]::PrimaryMonitorMaximizedWindowSize;	Write-Host "PrimaryMonitorMaximizedWindowSize   $PrimaryMonitorMaximizedWindowSize   "
		$PrimaryMonitorSize		= [Windows.Forms.SystemInformation]::PrimaryMonitorSize;	Write-Host "PrimaryMonitorSize   $PrimaryMonitorSize"
		$VirtualScreen			= [Windows.Forms.SystemInformation]::VirtualScreen;			Write-Host "VirtualScreen   $VirtualScreen"
		$WorkingArea			= [Windows.Forms.SystemInformation]::WorkingArea;			Write-Host "WorkingArea     $WorkingArea"

		# 呼び出し元に画面解像度を返す
		if( $null -ne $resolution ){
			$resolution.Value.x	= [Math]::Abs($rcWindow.right)  - [Math]::Abs($rcWindow.left);
			$resolution.Value.y	= [Math]::Abs($rcWindow.bottom) - [Math]::Abs($rcWindow.top);
			Write-Host "**** return value W=$($resolution.Value.x) H=$($resolution.Value.y) ****"
		}
	}
}


