



enum ScreenshotTarget {
	Primary		= 0
	Secondary	= 1
	# 3��ʖڈȍ~�͔�T�|�[�g
}


function Take-Screenshot( [ScreenshotTarget]$targetDisplay = ([ScreenshotTarget]::Primary), [string]$destPath = $PSScriptRoot )
{
	begin {	# 1�񂾂�����Ă����΂����悤�ȏ������L�ځBFor-Each object�ŌĂ΂��ƁA���[�v�����J�n�O��1��Ă΂��B

		Add-Type -AssemblyName System.Windows.Forms

		# Win32api��import
		Add-Type -MemberDefinition @"
		[DllImport("user32.dll", SetLastError=true)]
		public static extern short SetThreadDpiAwarenessContext(short dpiContext);
"@		-Namespace Win32 -Name NativeMethods

		# ��DPI�Ή��ςݐݒ�ɕύX(PowerShell�W���ݒ�ł͉�ʍ��W�擾���ɉ�ʊg�嗦�������������l��Ԃ����̂�)
		[int]$DpiOldSetting = [Win32.NativeMethods]::SetThreadDpiAwarenessContext(-3)

		# �o�͐�� Path + Filename �쐬
		[string]$filename = Get-Date -Format yyyyMMdd-HHmmss
		$filename = $filename + ".png"
		[string]$destFilePath = Join-Path $destPath $filename
		
		Write-Host ""
		Write-Host "Target screen : $([string]$targetDisplay)"
		Write-Host "Destination file : $destFilePath"
	}

	process{
		# �S��ʏ��擾
		[object]$Screens = [System.Windows.Forms.Screen]::AllScreens

		Write-Host "Display count : $($Screens.length)"
		if( $targetDisplay -gt ($Screens.length - 1) ){
			Write-Host -ForegroundColor Red "`n��ʕۑ��ΏۂƂ��āA���݂��Ȃ���ʂ��w�肵�Ă��܂��B���݂����ʐ��� $($Screens.length) �ł��B"
			exit -1
		}

		# �擾������ʏ�񂲂ƂɁA��Ɨ̈�̍��W���擾
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

				# Primary�łȂ��Ȃ� Secondary���ߑł��BPrimary�ȊO�� property����������B1PC��3��ʈȏオ�W���ɂȂ�� property��������̂��낤���E�E�E
				# 2��ʈȏ�ڑ����Ă���Ɖ�ʂ�������x�ɏ����㏑�������B�Ȃ̂�Secondary�Ƃ��Ắu�Ō�Ɍ���������ʂ̏��v���c��B
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
		

		[object]$bitmap = New-Object System.Drawing.Bitmap( $targetWidth, $targetHeight )	# Screenshot���B��̈�T�C�Y��bitmap objct���쐬
		[object]$image = [System.Drawing.Graphics]::FromImage( $bitmap )					# Screen image�擾�p�� image object���쐬
		$image.CopyFromScreen( (New-Object System.Drawing.Point($targetLeft,$targetTop)), (New-Object System.Drawing.Point(0,0)), $bitmap.size )
		$image.Dispose()					# image resource�p��
		$bitmap.Save( $destFilePath )
	}

	end {	# 1�񂾂�����Ă����΂����悤�ȏ������L�ځBFor-Each object�ŌĂ΂��ƁA���[�v�����I�����1��Ă΂��B
		# ��Dpi�Ή��ݒ�����ɖ߂�
		[void][Win32.NativeMethods]::SetThreadDpiAwarenessContext($DpiOldSetting)
	}
}


Take-Screenshot
