# Postman.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "Postman"
$ProgramExecutablePath = "C:\Program Files\Postman\Postman.exe"
$DownloadsPageURL = "https://dl.pstmn.io/download/latest/win64"
$TempDir = "$env:TEMP\PostmanInstaller"
$InstallerPattern = "Postman-win64-setup\.exe$"

New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

if (-not (Test-Path $ProgramExecutablePath)) {
    Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern
} else {
    Write-Log "$ProgramName is already installed." "INFO"
}