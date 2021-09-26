@echo off
pushd %~dp0

powershell -ExecutionPolicy RemoteSigned -WindowStyle Hidden -File ".\Set-SaveFolder.ps1"

popd
pause
