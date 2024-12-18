# NodeJS.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "Node.js"
$ProgramExecutablePath = "C:\Program Files\nodejs\node.exe"
$DownloadsPageURL = "https://nodejs.org/en/download/package-manager"
$TempDir = "$env:TEMP\NodeJSInstaller"
$InstallerPattern = "node-v.*-x64\.msi$"

New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

if (-not (Test-Path $ProgramExecutablePath)) {
    Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern
} else {
    Write-Log "$ProgramName is already installed." "INFO"
}