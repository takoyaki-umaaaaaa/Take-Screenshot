@echo off
pushd %~dp0
mshta vbscript:execute("MsgBox ""�����[�����񂷂Ǝ��`�݂Ă那�`���h�h , 323:close")

if not defined TakeScreenshot_SaveToFolder (
	echo ���ϐ� TakeScreenshot_SaveToFolder ��������Ȃ�

	rem powershell -ExecutionPolicy RemoteSigned -WindowStyle Hidden -File ".\Set-SaveFolder.ps1"
	powershell -ExecutionPolicy RemoteSigned -File ".\Set-SaveFolder.ps1"
)

if defined TakeScreenshot_SaveToFolder (
	echo ���ϐ� TakeScreenshot_SaveToFolder ����������
	echo %TakeScreenshot_SaveToFolder%

	rem powershell -ExecutionPolicy RemoteSigned -WindowStyle Hidden -File "%~dp0Take-Screenshot.ps1" %1 "%CD%"
	powershell -ExecutionPolicy RemoteSigned -File "%~dp0Take-Screenshot.ps1" 1 "%TakeScreenshot_SaveToFolder%"
)

popd
pause
