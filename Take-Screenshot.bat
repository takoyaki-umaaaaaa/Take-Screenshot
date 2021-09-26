@echo off
pushd %~dp0

powershell -ExecutionPolicy RemoteSigned -WindowStyle Hidden -File ".\Take-Screenshot.ps1"

popd
