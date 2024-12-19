# LibreCAD.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "LibreCAD"
$ProgramExecutablePath = "C:\Program Files\LibreCAD\LibreCAD.exe"
$DownloadsPageURL = "https://sourceforge.net/projects/librecad/files/Windows/"
$TempDir = "$env:TEMP\LibreCADInstaller"
$InstallerPattern = "LibreCAD-.*-installer\.exe$"

Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern