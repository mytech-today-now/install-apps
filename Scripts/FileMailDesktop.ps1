# FileMailDesktop.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "FileMail Desktop"
$ProgramExecutablePath = "C:\Program Files\Filemail Desktop\Filemail.exe"
$DownloadsPageURL = "https://www.filemail.com/apps/windows-desktop"
$TempDir = "$env:TEMP\FileMailDesktopInstaller"
$InstallerPattern = "Filemail.*\.exe$"

New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

if (-not (Test-Path $ProgramExecutablePath)) {
    Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern
} else {
    Write-Log "$ProgramName is already installed." "INFO"
}