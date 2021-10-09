# ���ݒ�
Set-StrictMode -Version 3.0
$ErrorActionPreference = "stop"						# �G���[�����������ꍇ�̓X�N���v�g�̎��s���~

. $PSScriptRoot\Utilities.ps1	# �^�̒�`�����邽�߁A�����X�R�[�v�Ɋ֐�����荞��
Add-Type -AssemblyName system.windows.forms
Add-Type -AssemblyName PresentationFramework

# �g�p����Win32 API���`
DefineWin32API


function dummyWindowXaml() {
return @"
	<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
			xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
			Title="�_�~�[�E�B���h�E" x:Name="basewindow" WindowStyle="None" SnapsToDevicePixels="True" ResizeMode="NoResize" 	Height="100" 	Width="100"	ShowInTaskbar = "False" FontFamily="UD Digi Kyokasho N-R" FontSize="18">
	<Grid Margin="0,0,0,0">
		<Label		x:Name="lbl1"	Content="abcdef����������"	Margin=" 5,  5, 0,  0"	VerticalAlignment="Top"	 />
		<Button		x:Name="btn1"	Margin="  0, 20, 10,  0"	HorizontalAlignment="Right"	VerticalAlignment="Top"		Height="34" 	Width="54"		Background="White"		Cursor="Hand"	VerticalContentAlignment="Bottom" />
	</Grid>
	</Window>
"@
}

function displayDummyWindow([IntPtr] $hPrentwnd, [ref]$rcResolution, [ref]$rcWorkarea) {
	[xml]$xaml = dummyWindowXaml
	[System.Xml.XmlNodeReader]$xamlReader = $xaml -as "System.Xml.XmlNodeReader"
	[object]$wndObj = [Windows.Markup.XamlReader]::Load( $xamlReader )
	
	# Control element�� object���擾
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

		# �Ăяo�����ɉ�ʉ𑜓x��Ԃ�
		$rcResolution.Value.left	= 0;
		$rcResolution.Value.top		= 0;
		$rcResolution.Value.right	= [Math]::Abs($rcWindow.right) - [Math]::Abs($rcWindow.left);
		$rcResolution.Value.bottom	= [Math]::Abs($rcWindow.bottom) - [Math]::Abs($rcWindow.top);
		Write-Host "**** return value W=$($rcResolution.Value.right) H=$($rcResolution.Value.bottom) ****"
	})

	$eleBtn.add_Click({ $eleWnd.Close() })
	$eleWnd.Add_MouseLeftButtonDown({ $eleWnd.DragMove() })
	$eleWnd.Add_MouseRightButtonDown({ $eleWnd.Close() })

	[object]$wih = New-Object System.Windows.Interop.WindowInteropHelper($wndObj)
	$wih.Owner = $hPrentwnd;		# �e��ݒ�

	if( $false ){
		# Dialog�\�� (Dialog��[����]�{�^�������܂ŋA���Ă��Ȃ�)
		[void]$wndObj.showDialog()

		Write-Host "W=$($rcResolution) H=$($rcResolution)"
	}
	else {
		$script:hwnd = $wih.EnsureHandle();	# Window��\�������ɍ쐬����

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

		# �Ăяo�����ɉ�ʉ𑜓x��Ԃ�
		$rcResolution.Value.left	= 0;
		$rcResolution.Value.top		= 0;
		$rcResolution.Value.right	= [Math]::Abs($rcWindow.right)  - [Math]::Abs($rcWindow.left);
		$rcResolution.Value.bottom	= [Math]::Abs($rcWindow.bottom) - [Math]::Abs($rcWindow.top);
		Write-Host "**** return value W=$($rcResolution.Value.right) H=$($rcResolution.Value.bottom) ****"
	}
}


