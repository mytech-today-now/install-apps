# LibreOffice.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "LibreOffice"
$ProgramExecutablePath = "C:\Program Files\LibreOffice\program\soffice.exe"
$DownloadsPageURL = "https://www.libreoffice.org/download/download-libreoffice/"
$TempDir = "$env:TEMP\LibreOfficeInstaller"
$InstallerPattern = "LibreOffice_.*_Win_x64\.msi$"

New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

if (-not (Test-Path $ProgramExecutablePath)) {
    Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern
} else {
    Write-Log "$ProgramName is already installed." "INFO"
}