# TweakingComWindowsRepair.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "Tweaking.com Windows Repair"
$ProgramExecutablePath = "C:\Program Files (x86)\Tweaking.com\Simple System Tweaker\Simple_System_Tweaker.exe"
$DownloadsPageURL = "https://www.tweaking.com/"
$TempDir = "$env:TEMP\TweakingComInstaller"
$InstallerPattern = "windows_repair_aio_setup.*\.exe$"

New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

if (-not (Test-Path $ProgramExecutablePath)) {
    Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern
} else {
    Write-Log "$ProgramName is already installed." "INFO"
}