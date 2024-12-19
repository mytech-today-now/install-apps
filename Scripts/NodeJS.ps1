# NodeJS.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "Node.js"
$ProgramExecutablePath = "C:\Program Files\nodejs\node.exe"
$DownloadsPageURL = "https://nodejs.org/en/download/package-manager"
$TempDir = "$env:TEMP\NodeJSInstaller"
$InstallerPattern = "node-v.*-x64\.msi$"

Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern