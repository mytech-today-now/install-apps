# ClipGrab.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "ClipGrab"
$ProgramExecutablePath = "C:\Program Files\ClipGrab\ClipGrab.exe"
$DownloadsPageURL = "https://clipgrab.org/"
$TempDir = "$env:TEMP\ClipGrabInstaller"
$InstallerPattern = "ClipGrab-.*\.exe$"

New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

if (-not (Test-Path $ProgramExecutablePath)) {
    Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern
} else {
    Write-Log "$ProgramName is already installed." "INFO"
}