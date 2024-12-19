# darktable.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "darktable"
$ProgramExecutablePath = "C:\Program Files\darktable\bin\darktable.exe"
$DownloadsPageURL = "https://www.darktable.org/"
$TempDir = "$env:TEMP\darktableInstaller"
$InstallerPattern = "darktable-.*-win64\.exe$"

Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern