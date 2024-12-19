# VSCode.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "Visual Studio Code"
$ProgramExecutablePath = "C:\Program Files\Microsoft VS Code\Code.exe"
$DownloadsPageURL = "https://code.visualstudio.com/download"
$TempDir = "$env:TEMP\VSCodeInstaller"
$InstallerPattern = "VSCodeSetup.*win32-x64.*\.exe$"

Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern