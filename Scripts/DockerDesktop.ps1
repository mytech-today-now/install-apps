# DockerDesktop.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "Docker Desktop"
$ProgramExecutablePath = "C:\Program Files\Docker\Docker\Docker Desktop.exe"
$DownloadsPageURL = "https://www.docker.com/products/docker-desktop/"
$TempDir = "$env:TEMP\DockerDesktopInstaller"
$InstallerPattern = "Docker Desktop Installer.*\.exe$"

New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

if (-not (Test-Path $ProgramExecutablePath)) {
    Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern
} else {
    Write-Log "$ProgramName is already installed." "INFO"
}