# BitcoinCore.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "Bitcoin Core"
$ProgramExecutablePath = "C:\Program Files\Bitcoin\bitcoin-qt.exe"
$DownloadsPageURL = "https://bitcoin.org/en/download"
$TempDir = "$env:TEMP\BitcoinCoreInstaller"
$InstallerPattern = "bitcoin-.*-win64-setup\.exe$"

New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

if (-not (Test-Path $ProgramExecutablePath)) {
    Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern
} else {
    Write-Log "$ProgramName is already installed." "INFO"
}