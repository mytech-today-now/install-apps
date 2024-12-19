# GIT.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "GIT"
$ProgramExecutablePath = "C:\Program Files\Git\bin\git.exe"
$DownloadsPageURL = "https://git-scm.com/downloads"
$TempDir = "$env:TEMP\GitInstaller"
$InstallerPattern = "Git-2.*-64-bit\.exe$"

Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern