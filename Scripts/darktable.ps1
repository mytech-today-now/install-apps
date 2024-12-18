# darktable.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "darktable"
$ProgramExecutablePath = "C:\Program Files\darktable\bin\darktable.exe"
$DownloadsPageURL = "https://www.darktable.org/"
$TempDir = "$env:TEMP\darktableInstaller"
$InstallerPattern = "darktable-.*-win64\.exe$"

New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

if (-not (Test-Path $ProgramExecutablePath)) {
    Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern
} else {
    Write-Log "$ProgramName is already installed." "INFO"
}