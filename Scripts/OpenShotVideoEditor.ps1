# OpenShotVideoEditor.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "OpenShot Video Editor"
$ProgramExecutablePath = "C:\Program Files\OpenShot Video Editor\openshot-qt.exe"
$DownloadsPageURL = "https://www.openshot.org/download/"
$TempDir = "$env:TEMP\OpenShotInstaller"
$InstallerPattern = "OpenShot-.*-Windows-x86_64\.exe$"

Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern