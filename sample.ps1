Add-Type -AssemblyName System.speech
$speak = New-Object System.Speech.Synthesis.SpeechSynthesizer
$speak.Speak('スクリーンショットを撮るスクリプトです。準備はよろしいですか？')
