# CoreFTP.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "Core FTP"
$ProgramExecutablePath = "C:\Program Files\CoreFTP\coreftp.exe"
$DownloadsPageURL = "https://www.coreftp.com/download.html"
$TempDir = "$env:TEMP\CoreFTPInstaller"
$InstallerPattern = "coreftp.*\.exe$"

Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern