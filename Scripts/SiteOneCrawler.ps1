# SiteOneCrawler.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "SiteOne Crawler"
$ProgramExecutablePath = "C:\Program Files\SiteOne Crawler\crawler.exe"
$DownloadsPageURL = "https://crawler.siteone.io/"
$TempDir = "$env:TEMP\SiteOneCrawlerInstaller"
$InstallerPattern = "SiteOneCrawlerSetup.*\.exe$"

Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern