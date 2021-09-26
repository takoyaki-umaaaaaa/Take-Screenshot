@echo off
pushd %~dp0


if not defined TAKESCREENSHOT_SAVETOFOLDER (
	echo 環境変数 TAKESCREENSHOT_SAVETOFOLDER が見つからない
	rem powershell -ExecutionPolicy RemoteSigned -WindowStyle Hidden -File ".\Set-SaveFolder.ps1"
	powershell -ExecutionPolicy RemoteSigned -File ".\Set-SaveFolder.ps1"
)

if defined TAKESCREENSHOT_SAVETOFOLDER (
	echo 環境変数 TAKESCREENSHOT_SAVETOFOLDER が見つかった
	echo %TAKESCREENSHOT_SAVETOFOLDER%
)

popd
pause
