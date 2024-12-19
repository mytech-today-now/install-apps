# Wireshark.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "Wireshark"
$ProgramExecutablePath = "C:\Program Files\Wireshark\Wireshark.exe"
$DownloadsPageURL = "https://www.wireshark.org/download.html"
$TempDir = "$env:TEMP\WiresharkInstaller"
$InstallerPattern = "Wireshark-win64-.*\.exe$"

Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern