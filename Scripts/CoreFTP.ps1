# CoreFTP.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "Core FTP"
$ProgramExecutablePath = "C:\Program Files\CoreFTP\coreftp.exe"
$DownloadsPageURL = "https://www.coreftp.com/download.html"
$TempDir = "$env:TEMP\CoreFTPInstaller"
$InstallerPattern = "coreftp.*\.exe$"

New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

if (-not (Test-Path $ProgramExecutablePath)) {
    Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern
} else {
    Write-Log "$ProgramName is already installed." "INFO"
}