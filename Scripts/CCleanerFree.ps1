# CCleanerFree.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "CCleaner Free"
$ProgramExecutablePath = "C:\Program Files\CCleaner\CCleaner.exe"
$DownloadsPageURL = "https://www.ccleaner.com/ccleaner/download"
$TempDir = "$env:TEMP\CCleanerInstaller"
$InstallerPattern = "ccsetup.*\.exe$"

New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

if (-not (Test-Path $ProgramExecutablePath)) {
    Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern
} else {
    Write-Log "$ProgramName is already installed." "INFO"
}