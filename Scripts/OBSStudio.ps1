# OBSStudio.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "OBS Studio"
$ProgramExecutablePath = "C:\Program Files\obs-studio\bin\64bit\obs64.exe"
$DownloadsPageURL = "https://obsproject.com/"
$TempDir = "$env:TEMP\OBSStudioInstaller"
$InstallerPattern = "OBS-Studio-.*-Full-Installer-x64\.exe$"

New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

if (-not (Test-Path $ProgramExecutablePath)) {
    Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern
} else {
    Write-Log "$ProgramName is already installed." "INFO"
}