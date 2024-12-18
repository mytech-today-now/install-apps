# BelarcAdvisor.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "Belarc Advisor"
$ProgramExecutablePath = "C:\Program Files (x86)\Belarc\BelarcAdvisor\BelarcAdvisor.exe"
$DownloadsPageURL = "https://www.majorgeeks.com/files/details/belarc_advisor.html"
$TempDir = "$env:TEMP\BelarcAdvisorInstaller"
$InstallerPattern = "AdvisorInstaller.*\.exe$"

New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

if (-not (Test-Path $ProgramExecutablePath)) {
    Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern
} else {
    Write-Log "$ProgramName is already installed." "INFO"
}