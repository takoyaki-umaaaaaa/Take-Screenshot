@echo off
pushd %~dp0

	rem powershell -ExecutionPolicy RemoteSigned -WindowStyle Hidden -File "%~dp0main.ps1" %1 "%CD%"
	powershell -ExecutionPolicy RemoteSigned -File "%~dp0main.ps1" 0 "%TakeScreenshot_SaveToFolder%"
)

popd
pause
