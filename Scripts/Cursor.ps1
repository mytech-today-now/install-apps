# Cursor.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "Cursor"
$ProgramExecutablePath = "C:\Program Files\Cursor\Cursor.exe"
$DownloadsPageURL = "https://www.cursor.com/downloads"
$TempDir = "$env:TEMP\CursorInstaller"
$InstallerPattern = "Cursor-.*-Setup\.exe$"

New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

if (-not (Test-Path $ProgramExecutablePath)) {
    Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern
} else {
    Write-Log "$ProgramName is already installed." "INFO"
}