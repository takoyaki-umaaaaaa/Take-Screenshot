@echo off
pushd %~dp0

rem powershell -ExecutionPolicy RemoteSigned -WindowStyle Hidden -File ".\settings.ps1"
powershell -ExecutionPolicy RemoteSigned -File ".\settings.ps1"

popd
pause
