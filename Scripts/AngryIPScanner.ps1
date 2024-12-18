# AngryIPScanner.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "Angry IP Scanner"
$ProgramExecutablePath = "C:\Program Files\Angry IP Scanner\ipscan.exe"
$DownloadsPageURL = "https://angryip.org/download/#windows"
$TempDir = "$env:TEMP\AngryIPScannerInstaller"
$InstallerPattern = "ipscan-.*-setup\.exe$"

New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

if (-not (Test-Path $ProgramExecutablePath)) {
    Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern
} else {
    Write-Log "$ProgramName is already installed." "INFO"
}