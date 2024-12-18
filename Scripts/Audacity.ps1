# Audacity.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "Audacity"
$ProgramExecutablePath = "C:\Program Files\Audacity\audacity.exe"
$DownloadsPageURL = "https://www.audacityteam.org/download/"
$TempDir = "$env:TEMP\AudacityInstaller"
$InstallerPattern = "audacity-win-.*-x64\.exe$"

New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

if (-not (Test-Path $ProgramExecutablePath)) {
    Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern
} else {
    Write-Log "$ProgramName is already installed." "INFO"
}