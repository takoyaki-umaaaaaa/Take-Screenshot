
[string]$resource_img_setting= Join-Path "$PSScriptRoot" "\resource\Setting.png"
$global:Controls = 
	@([pscustomobject]@{ Name="lbl_title";				Content="設定";							Element=$null},
	  [pscustomobject]@{ Name="lbl_SaveFolder";			Content="画像保存先";					Element=$null},
	  [pscustomobject]@{ Name="txt_SaveFolder";			Content="";								Element=$null},
	  [pscustomobject]@{ Name="btn_SelectFolder";		Content="…"; 							Element=$null},
	  [pscustomobject]@{ Name="btn_DeleteEnvVal";		Content="保存先情報を削除";				Element=$null},
	  [pscustomobject]@{ Name="chk_DisplayImage";		Content="保存後に画像を表示";			Element=$null},
	  [pscustomobject]@{ Name="btn_RegisterInStart";	Content="スタートメニューに登録する";	Element=$null},
	  [pscustomobject]@{ Name="btn_Uninstall";			Content="アンインストール";				Element=$null},
	  [pscustomobject]@{ Name="btn_Close";				Content="閉じる";						Element=$null},
	  [pscustomobject]@{ Name="img_Background";			Content="";								Element=$null})



$global:SettingDlgXaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
		xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
		Title="設定画面" Height="515.25" Width="462.917" WindowStyle="ThreeDBorderWindow" SnapsToDevicePixels="True" ResizeMode="CanResizeWithGrip"  MinWidth="400" MinHeight="500">
	<Grid Margin="-1,0,-2,-2">
		<Grid.Background>
			<LinearGradientBrush EndPoint="1,1" StartPoint="0,0">
				<LinearGradientBrush.RelativeTransform>
					<TransformGroup>
						<ScaleTransform  CenterY="0.5" CenterX="0.5"/>
						<SkewTransform   CenterY="0.5" CenterX="0.5"/>
						<RotateTransform CenterY="0.5" CenterX="0.5"/>
						<TranslateTransform/>
					</TransformGroup>
				</LinearGradientBrush.RelativeTransform>
				<GradientStop Color="#FFF0F0F0"/>
				<GradientStop Color="#FFD7D7D7" Offset="1"/>
				<GradientStop Color="#FFB6B6B6" Offset="0.988"/>
				<GradientStop Color="#FFE2E2E2" Offset="0.155"/>
			</LinearGradientBrush>
		</Grid.Background>
		<Label		x:Name="$($global:Controls[0].Name)"	Content="$($global:Controls[0].Content)"	HorizontalAlignment="Left"	Margin="24,10,0,0"			VerticalAlignment="Top"		Height="45" 	Width="122"	FontSize="24" />
		<Label		x:Name="$($global:Controls[1].Name)"	Content="$($global:Controls[1].Content)"	HorizontalAlignment="Left"	Margin="50,75,0,0"			VerticalAlignment="Top"						Width="118"	FontSize="18"	HorizontalContentAlignment="Right" />
		<TextBox	x:Name="$($global:Controls[2].Name)"																			Margin="168,75,120.333,0"	VerticalAlignment="Top"		Height="34"					FontSize="18"	IsUndoEnabled="False" MaxLines="1" />
		<Button		x:Name="$($global:Controls[3].Name)"	Content="$($global:Controls[3].Content)" 	HorizontalAlignment="Right"	Margin="0,75,41.333,0"		VerticalAlignment="Top"		Height="34" 	Width="79"	FontSize="18"	/>
		<Button		x:Name="$($global:Controls[4].Name)"	Content="$($global:Controls[4].Content)"								Margin="50,132,41,0"		VerticalAlignment="Top"		Height="53"					FontSize="18"	/>
		<CheckBox	x:Name="$($global:Controls[5].Name)"	Content="$($global:Controls[5].Content)" 	HorizontalAlignment="Left"	Margin="50,210,0,0"			VerticalAlignment="Top"									FontSize="18"	VerticalContentAlignment="Center" />
		<Button		x:Name="$($global:Controls[6].Name)"	Content="$($global:Controls[6].Content)"	HorizontalAlignment="Left"	Margin="50,255,0,0"			VerticalAlignment="Top"		Height="45"		Width="223"	FontSize="18"	/>
		<Button		x:Name="$($global:Controls[7].Name)"	Content="$($global:Controls[7].Content)"	HorizontalAlignment="Left"	Margin="50,327,0,0"			VerticalAlignment="Top"		Height="42"		Width="223"	FontSize="18"	Foreground="Red" BorderBrush="Red" />
		<Button		x:Name="$($global:Controls[8].Name)"	Content="$($global:Controls[8].Content)"	HorizontalAlignment="Right" Margin="0,0,41,34"			VerticalAlignment="Bottom"	Height="87"		Width="114"	FontSize="18" />
		<Image		x:Name="$($global:Controls[9].Name)"												HorizontalAlignment="Left"	Margin="-60,190,0,-57"		VerticalAlignment="Top"		Height="358"	Width="361"					Source="$resource_img_setting" Panel.ZIndex="-100">
			<Image.OpacityMask>
				<ImageBrush ImageSource="$resource_img_setting" Stretch="Uniform" Opacity="0.3"/>
			</Image.OpacityMask>
		</Image>
	</Grid>
</Window>
"@
