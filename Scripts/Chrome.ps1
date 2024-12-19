# Chrome.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "Google Chrome"
$ProgramExecutablePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"
$DownloadsPageURL = "https://www.google.com/chrome/"
$TempDir = "$env:TEMP\ChromeInstaller"
$InstallerPattern = "ChromeSetup\.exe$"

Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern