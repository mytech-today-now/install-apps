# Wireshark.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "Wireshark"
$ProgramExecutablePath = "C:\Program Files\Wireshark\Wireshark.exe"
$DownloadsPageURL = "https://www.wireshark.org/download.html"
$TempDir = "$env:TEMP\WiresharkInstaller"
$InstallerPattern = "Wireshark-win64-.*\.exe$"

New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

if (-not (Test-Path $ProgramExecutablePath)) {
    Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern
} else {
    Write-Log "$ProgramName is already installed." "INFO"
}