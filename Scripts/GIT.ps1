# GIT.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "GIT"
$ProgramExecutablePath = "C:\Program Files\Git\bin\git.exe"
$DownloadsPageURL = "https://git-scm.com/downloads"
$TempDir = "$env:TEMP\GitInstaller"
$InstallerPattern = "Git-2.*-64-bit\.exe$"

New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

if (-not (Test-Path $ProgramExecutablePath)) {
    Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern
} else {
    Write-Log "$ProgramName is already installed." "INFO"
}