# OpenShotVideoEditor.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "OpenShot Video Editor"
$ProgramExecutablePath = "C:\Program Files\OpenShot Video Editor\openshot-qt.exe"
$DownloadsPageURL = "https://www.openshot.org/download/"
$TempDir = "$env:TEMP\OpenShotInstaller"
$InstallerPattern = "OpenShot-.*-Windows-x86_64\.exe$"

New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

if (-not (Test-Path $ProgramExecutablePath)) {
    Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern
} else {
    Write-Log "$ProgramName is already installed." "INFO"
}