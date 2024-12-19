# BitcoinCore.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "Bitcoin Core"
$ProgramExecutablePath = "C:\Program Files\Bitcoin\bitcoin-qt.exe"
$DownloadsPageURL = "https://bitcoin.org/en/download"
$TempDir = "$env:TEMP\BitcoinCoreInstaller"
$InstallerPattern = "bitcoin-.*-win64-setup\.exe$"

Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern