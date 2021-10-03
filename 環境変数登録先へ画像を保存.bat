@echo off
pushd %~dp0

	powershell -ExecutionPolicy RemoteSigned -WindowStyle Hidden -File "%~dp0main.ps1" 0 "%TakeScreenshot_SaveToFolder%"
	rem powershell -ExecutionPolicy RemoteSigned -File "%~dp0main.ps1" 0 "%TakeScreenshot_SaveToFolder%"
)

popd
pause
