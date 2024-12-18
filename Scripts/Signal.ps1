# SignalMessenger.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "Signal"
$ProgramExecutablePath = "C:\Program Files\Signal\Signal.exe"
$DownloadsPageURL = "https://signal.org/download/"
$TempDir = "$env:TEMP\SignalInstaller"
$InstallerPattern = "Signal.*\.exe$"

New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

if (-not (Test-Path $ProgramExecutablePath)) {
    Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern
} else {
    Write-Log "$ProgramName is already installed." "INFO"
}