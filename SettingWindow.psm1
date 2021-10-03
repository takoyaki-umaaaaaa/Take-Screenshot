
$res_img_background	= Join-Path "$PSScriptRoot" "\resource\Gear2.png"
$res_ico_delete		= Join-Path "$PSScriptRoot" "\resource\eraser.png"
$res_ico_trashcan	= Join-Path "$PSScriptRoot" "\resource\TrashCan.png"
$res_ico_folder		= Join-Path "$PSScriptRoot" "\resource\Folder.png"
$res_ico_exit		= Join-Path "$PSScriptRoot" "\resource\Exit.png"
$res_ico_start		= Join-Path "$PSScriptRoot" "\resource\Start.png"


$global:Controls = 
	@([pscustomobject]@{ Name="lbl_title";				Content="設定";							Element=$null},	# 0
	  [pscustomobject]@{ Name="lbl_SaveFolder";			Content="画像保存先";					Element=$null},	# 1
	  [pscustomobject]@{ Name="txt_SaveFolder";			Content="";								Element=$null},	# 2
	  [pscustomobject]@{ Name="btn_SelectFolder";		Content="…"; 							Element=$null},	# 3
	  [pscustomobject]@{ Name="btn_DeleteEnvVal";		Content="保存先情報を削除";				Element=$null},	# 4
	  [pscustomobject]@{ Name="chk_DisplayImage";		Content="保存後に画像を表示";			Element=$null},	# 5
	  [pscustomobject]@{ Name="btn_RegisterInStart";	Content="スタートメニューに登録する";	Element=$null},	# 6
	  [pscustomobject]@{ Name="btn_Uninstall";			Content="アンインストール";				Element=$null},	# 7
	  [pscustomobject]@{ Name="btn_Close";				Content="閉じる";						Element=$null},	# 8
	  [pscustomobject]@{ Name="img_Background";			Content="";								Element=$null})	# 9



$global:SettingDlgXaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
		xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
		Title="設定画面" Height="515" Width="460" WindowStyle="ThreeDBorderWindow" SnapsToDevicePixels="True" ResizeMode="CanResizeWithGrip"  MinWidth="400" MinHeight="500"  FontFamily="UD Digi Kyokasho N-R" FontSize="18" Icon="$res_img_background">
	<Grid Margin="0,0,0,0">
		<Grid.Background>
			<LinearGradientBrush EndPoint="1,1" StartPoint="0,0">
				<GradientStop Color="White"/>
				<GradientStop Color="#FFD7D7D7" Offset="1"/>
				<GradientStop Color="#FFBCBCBC" Offset="0.988"/>
				<GradientStop Color="#FFEAEAEA" Offset="0.81"/>
			</LinearGradientBrush>
		</Grid.Background>
		<Label		x:Name="$($global:Controls[0].Name)"	Content="$($global:Controls[0].Content)"	Margin=" 40,  4, 40,  0"								VerticalAlignment="Top"																				FontSize="48" />
		<Label		x:Name="$($global:Controls[1].Name)"	Content="$($global:Controls[1].Content)"	Margin=" 40, 75,  0,  0"	HorizontalAlignment="Left"	VerticalAlignment="Top"																				HorizontalContentAlignment="Right" />
		<TextBox	x:Name="$($global:Controls[2].Name)"												Margin="145, 75, 93,  0"								VerticalAlignment="Top"		Height="34"												Cursor="Pen"	VerticalContentAlignment="Center" IsUndoEnabled="False" MaxLines="1" />
		<Button		x:Name="$($global:Controls[3].Name)"												Margin="  0, 75, 40,  0"	HorizontalAlignment="Right"	VerticalAlignment="Top"		Height="34" 	Width="54"		Background="White"		Cursor="Hand"	VerticalContentAlignment="Bottom" >
			<Image x:Name="image10" Source="$res_ico_folder" Margin="3,3,3,3" Height="22" Width="22"/>
		</Button>
		<Button		x:Name="$($global:Controls[4].Name)"												Margin=" 40,132, 41,  0"								VerticalAlignment="Top"		Height="53"						Background="White"		Cursor="Hand"	>
			<StackPanel Orientation="Horizontal">
				<Image x:Name="image1" Source="$res_ico_delete" Margin="10,10,0,10" Height="22" Width="22"/>
				<Label x:Name="label1" Content="$($global:Controls[4].Content)" VerticalContentAlignment="Center"/>
			</StackPanel>
		</Button>
		<CheckBox	x:Name="$($global:Controls[5].Name)"	Content="$($global:Controls[5].Content)" 	Margin=" 40,210,  0,  0"	HorizontalAlignment="Left"	VerticalAlignment="Top"																Cursor="Hand"	VerticalContentAlignment="Center" />
		<Button		x:Name="$($global:Controls[6].Name)"												Margin=" 40,255,  0,  0"	HorizontalAlignment="Left"	VerticalAlignment="Top"		Height="45"		Width="300"		Background="White"		Cursor="Hand"	>
			<StackPanel Orientation="Horizontal">
				<Image x:Name="image2" Source="$res_ico_start" Margin="5,5,0,5" Height="22" Width="22"/>
				<Label x:Name="label2" Content="$($global:Controls[6].Content)" VerticalContentAlignment="Center"/>
			</StackPanel>
		</Button>
		<Button		x:Name="$($global:Controls[7].Name)"												Margin=" 40,327,  0,  0"	HorizontalAlignment="Left"	VerticalAlignment="Top"		Height="42"		Width="300"		Background="White"		Cursor="Hand"	BorderBrush="Red" >
			<StackPanel Orientation="Horizontal">
				<Image x:Name="image3" Source="$res_ico_trashcan" Margin="5,5,0,5" Height="30" Width="30"/>
				<Label x:Name="label3" Content="$($global:Controls[7].Content)" VerticalContentAlignment="Center" 	Foreground="Red"/>
			</StackPanel>
		</Button>
		<Button		x:Name="$($global:Controls[8].Name)"												Margin="  0,  0, 40, 31"	HorizontalAlignment="Right" VerticalAlignment="Bottom"	Height="64"		Width="150"		Background="White"		Cursor="Hand"	IsDefault="True" >
			<StackPanel Orientation="Horizontal">
				<Image x:Name="image4" Source="$res_ico_exit" Margin="5,5,0,5" Height="30" Width="30"/>
				<Label x:Name="label4" Content="$($global:Controls[8].Content)" VerticalContentAlignment="Center"/>
			</StackPanel>
		</Button>
		<Image		x:Name="$($global:Controls[9].Name)"												Margin="145,210,-45,-77"																																	Source="$res_img_background" Panel.ZIndex="-100" Opacity="0.3" />
	</Grid>
</Window>
"@
