# ClownfishVoiceChanger.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "Clownfish Voice Changer"
$ProgramExecutablePath = "C:\Program Files (x86)\ClownfishVoiceChanger\ClownfishVoiceChanger.exe"
$DownloadsPageURL = "https://clownfish-translator.com/voicechanger/download.html"
$TempDir = "$env:TEMP\ClownfishInstaller"
$InstallerPattern = "ClownfishVoiceChanger.*\.exe$"

New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

if (-not (Test-Path $ProgramExecutablePath)) {
    Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern
} else {
    Write-Log "$ProgramName is already installed." "INFO"
}