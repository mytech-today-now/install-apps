# Opera.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "Opera"
$ProgramExecutablePath = "C:\Program Files\Opera\opera.exe"
$DownloadsPageURL = "https://www.opera.com/computer/thanks?ni=stable&os=windows"
$TempDir = "$env:TEMP\OperaInstaller"
$InstallerPattern = "OperaSetup\.exe$"

Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern