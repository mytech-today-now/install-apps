# Gimp.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "GIMP-2_is1"
$ProgramExecutablePath = "C:\Program Files\GIMP 2\bin\gimp-2.10.exe"
$DownloadsPageURL = "https://www.gimp.org/downloads/"
$TempDir = "$env:TEMP\GIMPInstaller"
$InstallerPattern = "/gimp/v[\d\.]+/windows/gimp-[\d\.]+-setup\.exe$"

New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

if (-not (Test-Path $ProgramExecutablePath)) {
    Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern
} else {
    Write-Log "$ProgramName is already installed." "INFO"
}