# InstantEyeDropper.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "Instant Eyedropper"
$ProgramExecutablePath = "C:\Program Files (x86)\InstantEyedropper\InstantEyedropper.exe"
$DownloadsPageURL = "http://instant-eyedropper.com/"
$TempDir = "$env:TEMP\InstantEyeDropperInstaller"
$InstallerPattern = "InstantEyedropper.*\.exe$"

New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

if (-not (Test-Path $ProgramExecutablePath)) {
    Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern
} else {
    Write-Log "$ProgramName is already installed." "INFO"
}