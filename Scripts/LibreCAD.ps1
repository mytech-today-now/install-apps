# LibreCAD.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "LibreCAD"
$ProgramExecutablePath = "C:\Program Files\LibreCAD\LibreCAD.exe"
$DownloadsPageURL = "https://sourceforge.net/projects/librecad/files/Windows/"
$TempDir = "$env:TEMP\LibreCADInstaller"
$InstallerPattern = "LibreCAD-.*-installer\.exe$"

New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

if (-not (Test-Path $ProgramExecutablePath)) {
    Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern
} else {
    Write-Log "$ProgramName is already installed." "INFO"
}