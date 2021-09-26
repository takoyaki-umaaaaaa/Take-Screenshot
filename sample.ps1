Add-Type -AssemblyName System.speech
$speak = New-Object System.Speech.Synthesis.SpeechSynthesizer


$speak.GetInstalledVoices() | select -ExpandProperty VoiceInfo | select Name, Gender, Description


$speak.SelectVoice("Microsoft Haruka Desktop")
$speak.Speak('�X�N���[���V���b�g���B��X�N���v�g�ł��B�����͂�낵���ł����H')
# $speak.Speak("This is a script that takes screenshots.")
