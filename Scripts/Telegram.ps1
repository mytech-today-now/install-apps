# Telegram.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "Telegram"
$ProgramExecutablePath = "C:\Program Files\Telegram Desktop\Telegram.exe"
$DownloadsPageURL = "https://desktop.telegram.org/"
$TempDir = "$env:TEMP\TelegramInstaller"
$InstallerPattern = "tsetup.*\.exe$"

New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

if (-not (Test-Path $ProgramExecutablePath)) {
    Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern
} else {
    Write-Log "$ProgramName is already installed." "INFO"
}