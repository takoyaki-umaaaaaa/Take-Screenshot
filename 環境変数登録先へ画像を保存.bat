@echo off
pushd %~dp0


if not defined TAKESCREENSHOT_SAVETOFOLDER (
	echo ���ϐ� TAKESCREENSHOT_SAVETOFOLDER ��������Ȃ�
	rem powershell -ExecutionPolicy RemoteSigned -WindowStyle Hidden -File ".\Set-SaveFolder.ps1"
	powershell -ExecutionPolicy RemoteSigned -File ".\Set-SaveFolder.ps1"
)

if defined TAKESCREENSHOT_SAVETOFOLDER (
	echo ���ϐ� TAKESCREENSHOT_SAVETOFOLDER ����������
	echo %TAKESCREENSHOT_SAVETOFOLDER%
)

popd
pause
