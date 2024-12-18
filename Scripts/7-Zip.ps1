# 7-Zip.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "7-Zip"
$ProgramExecutablePath = "C:\Program Files\7-Zip\7zFM.exe"
$DownloadsPageURL = "https://www.7-zip.org/download.html"
$TempDir = "$env:TEMP\7ZipInstaller"
$InstallerPattern = "7z.*\.exe$"

New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

if (-not (Test-Path $ProgramExecutablePath)) {
    Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern
} else {
    Write-Log "$ProgramName is already installed." "INFO"
}