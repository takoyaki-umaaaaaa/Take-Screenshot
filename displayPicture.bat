@echo off
pushd %~dp0

rem powershell -ExecutionPolicy RemoteSigned -WindowStyle Hidden -File ".\DisplayPicture.ps1"
powershell -ExecutionPolicy RemoteSigned -File ".\DisplayPicture.ps1"

popd
pause
