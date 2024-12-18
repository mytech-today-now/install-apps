# Chrome.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "Google Chrome"
$ProgramExecutablePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"
$DownloadsPageURL = "https://www.google.com/chrome/"
$TempDir = "$env:TEMP\ChromeInstaller"
$InstallerPattern = "ChromeSetup\.exe$"

New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

if (-not (Test-Path $ProgramExecutablePath)) {
    Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern
} else {
    Write-Log "$ProgramName is already installed." "INFO"
}