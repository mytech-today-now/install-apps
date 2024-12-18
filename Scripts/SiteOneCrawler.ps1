# SiteOneCrawler.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "SiteOne Crawler"
$ProgramExecutablePath = "C:\Program Files\SiteOne Crawler\crawler.exe"
$DownloadsPageURL = "https://crawler.siteone.io/"
$TempDir = "$env:TEMP\SiteOneCrawlerInstaller"
$InstallerPattern = "SiteOneCrawlerSetup.*\.exe$"

New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

if (-not (Test-Path $ProgramExecutablePath)) {
    Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern
} else {
    Write-Log "$ProgramName is already installed." "INFO"
}