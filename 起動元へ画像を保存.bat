@echo off
rem Shortcut file (.lnk) ����̋N���p batch file
rem �Ăяo������ .lnk ������t�H���_�� Screenshot�摜��ۑ�����
rem (.lnk �́u��ƃt�H���_�v���󔒂ɂ��邱�Ƃ� Current �� .lnk ������t�H���_�ɂ��Ă���)
rem (Batch file �ւ� Path �́A���� %0 �̏����g���Ă���)

echo.
echo [Shortcut file (.lnk) �N������ Screenshot�ۑ�]
echo �N����(�摜�o�͐�) : %CD%
echo Script�u���� : %~dp0
rem pushd %~dp0

rem powershell -ExecutionPolicy RemoteSigned -WindowStyle Hidden -File "%~dp0main.ps1" %1 "%CD%"
    powershell -ExecutionPolicy RemoteSigned                     -File "%~dp0main.ps1" %1 "%CD%"

rem popd
pause
