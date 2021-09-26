@echo off
pushd %~dp0

if not defined TakeScreenshot_SaveToFolder (
	echo 環境変数 TakeScreenshot_SaveToFolder が見つからない

	rem powershell -ExecutionPolicy RemoteSigned -WindowStyle Hidden -File ".\Set-SaveFolder.ps1"
	powershell -ExecutionPolicy RemoteSigned -File ".\Set-SaveFolder.ps1"
)

if defined TakeScreenshot_SaveToFolder (
	echo 環境変数 TakeScreenshot_SaveToFolder が見つかった
	echo %TakeScreenshot_SaveToFolder%

	rem powershell -ExecutionPolicy RemoteSigned -WindowStyle Hidden -File "%~dp0Take-Screenshot.ps1" %1 "%CD%"
	powershell -ExecutionPolicy RemoteSigned -File "%~dp0Take-Screenshot.ps1" 1 "%TakeScreenshot_SaveToFolder%"
)

popd
pause
