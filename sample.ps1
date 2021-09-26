Add-Type -AssemblyName System.speech
$speak = New-Object System.Speech.Synthesis.SpeechSynthesizer


$speak.GetInstalledVoices() | select -ExpandProperty VoiceInfo | select Name, Gender, Description


$speak.SelectVoice("Microsoft Haruka Desktop")
$speak.Speak('スクリーンショットを撮るスクリプトです。準備はよろしいですか？')
# $speak.Speak("This is a script that takes screenshots.")
