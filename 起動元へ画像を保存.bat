@echo off
rem Shortcut file (.lnk) からの起動用 batch file
rem 呼び出し元の .lnk があるフォルダに Screenshot画像を保存する
rem (.lnk の「作業フォルダ」を空白にすることで Current を .lnk があるフォルダにしている)
rem (Batch file への Path は、引数 %0 の情報を使っている)

echo.
echo [Shortcut file (.lnk) 起動元へ Screenshot保存]
echo 起動元(画像出力先) : %CD%
echo Script置き場 : %~dp0
rem pushd %~dp0

rem powershell -ExecutionPolicy RemoteSigned -WindowStyle Hidden -File "%~dp0main.ps1" %1 "%CD%"
    powershell -ExecutionPolicy RemoteSigned                     -File "%~dp0main.ps1" %1 "%CD%"

rem popd
pause
