@echo off
pushd %~dp0


if not defined TAKESCREENSHOT_SAVETOFOLDER (
	echo ŠÂ‹«•Ï” TAKESCREENSHOT_SAVETOFOLDER ‚ªŒ©‚Â‚©‚ç‚È‚¢
	rem powershell -ExecutionPolicy RemoteSigned -WindowStyle Hidden -File ".\Set-SaveFolder.ps1"
	powershell -ExecutionPolicy RemoteSigned -File ".\Set-SaveFolder.ps1"
)

if defined TAKESCREENSHOT_SAVETOFOLDER (
	echo ŠÂ‹«•Ï” TAKESCREENSHOT_SAVETOFOLDER ‚ªŒ©‚Â‚©‚Á‚½
	echo %TAKESCREENSHOT_SAVETOFOLDER%
)

popd
pause
