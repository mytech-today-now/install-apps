# Telegram.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "Telegram"
$ProgramExecutablePath = "C:\Program Files\Telegram Desktop\Telegram.exe"
$DownloadsPageURL = "https://desktop.telegram.org/"
$TempDir = "$env:TEMP\TelegramInstaller"
$InstallerPattern = "tsetup.*\.exe$"

Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern