# Cursor.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "Cursor"
$ProgramExecutablePath = "C:\Program Files\Cursor\Cursor.exe"
$DownloadsPageURL = "https://www.cursor.com/downloads"
$TempDir = "$env:TEMP\CursorInstaller"
$InstallerPattern = "Cursor-.*-Setup\.exe$"

Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern