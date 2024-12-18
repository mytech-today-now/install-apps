# Brave.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "Brave Browser"
$ProgramExecutablePath = "C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe"
$DownloadsPageURL = "https://brave.com/download/"
$TempDir = "$env:TEMP\BraveInstaller"
$InstallerPattern = "BraveBrowserSetup.*\.exe$"

New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

if (-not (Test-Path $ProgramExecutablePath)) {
    Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern
} else {
    Write-Log "$ProgramName is already installed." "INFO"
}