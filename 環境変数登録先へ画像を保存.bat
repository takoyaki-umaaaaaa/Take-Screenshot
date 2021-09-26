@echo off
pushd %~dp0
mshta vbscript:execute("MsgBox ""‚¢‚¦[‚¢‚­‚ñ‚·‚Æ`‚İ‚Ä‚é‚£`‚—hh , 323:close")

if not defined TakeScreenshot_SaveToFolder (
	echo ŠÂ‹«•Ï” TakeScreenshot_SaveToFolder ‚ªŒ©‚Â‚©‚ç‚È‚¢

	rem powershell -ExecutionPolicy RemoteSigned -WindowStyle Hidden -File ".\Set-SaveFolder.ps1"
	powershell -ExecutionPolicy RemoteSigned -File ".\Set-SaveFolder.ps1"
)

if defined TakeScreenshot_SaveToFolder (
	echo ŠÂ‹«•Ï” TakeScreenshot_SaveToFolder ‚ªŒ©‚Â‚©‚Á‚½
	echo %TakeScreenshot_SaveToFolder%

	rem powershell -ExecutionPolicy RemoteSigned -WindowStyle Hidden -File "%~dp0Take-Screenshot.ps1" %1 "%CD%"
	powershell -ExecutionPolicy RemoteSigned -File "%~dp0Take-Screenshot.ps1" 1 "%TakeScreenshot_SaveToFolder%"
)

popd
pause
