# HandBrake.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "HandBrake"
$ProgramExecutablePath = "C:\Program Files\HandBrake\HandBrake.exe"
$DownloadsPageURL = "https://handbrake.fr/downloads.php"
$TempDir = "$env:TEMP\HandBrakeInstaller"
$InstallerPattern = "HandBrake.*\.exe$"

New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

if (-not (Test-Path $ProgramExecutablePath)) {
    Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern
} else {
    Write-Log "$ProgramName is already installed." "INFO"
}