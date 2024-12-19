# NotePadPlusPlus.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "Notepad++"
$ProgramExecutablePath = "C:\Program Files\Notepad++\notepad++.exe"
$DownloadsPageURL = "https://notepad-plus-plus.org/downloads/"
$TempDir = "$env:TEMP\NotepadPlusPlusInstaller"
$InstallerPattern = "/releases/latest/download/npp\w+_Installer\.exe$"

Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern