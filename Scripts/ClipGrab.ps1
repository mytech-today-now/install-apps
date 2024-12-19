# ClipGrab.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "ClipGrab"
$ProgramExecutablePath = "C:\Program Files\ClipGrab\ClipGrab.exe"
$DownloadsPageURL = "https://clipgrab.org/"
$TempDir = "$env:TEMP\ClipGrabInstaller"
$InstallerPattern = "ClipGrab-.*\.exe$"

Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern