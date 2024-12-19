# SignalMessenger.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "Signal"
$ProgramExecutablePath = "C:\Program Files\Signal\Signal.exe"
$DownloadsPageURL = "https://signal.org/download/"
$TempDir = "$env:TEMP\SignalInstaller"
$InstallerPattern = "Signal.*\.exe$"

Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern