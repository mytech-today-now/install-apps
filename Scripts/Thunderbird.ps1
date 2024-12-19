# Thunderbird.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "Thunderbird"
$ProgramExecutablePath = "C:\Program Files\Mozilla Thunderbird\thunderbird.exe"
$DownloadsPageURL = "https://www.thunderbird.net/en-US/download/"
$TempDir = "$env:TEMP\ThunderbirdInstaller"
$InstallerPattern = "Thunderbird%20Setup.*\.exe$"

Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern