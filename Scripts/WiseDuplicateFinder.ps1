# WiseDuplicateFinder.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "Wise Duplicate Finder"
$ProgramExecutablePath = "C:\Program Files (x86)\Wise\Wise Duplicate Finder\WiseDuplicateFinder.exe"
$DownloadsPageURL = "https://www.wisecleaner.com/wise-duplicate-finder.html"
$TempDir = "$env:TEMP\WiseDuplicateFinderInstaller"
$InstallerPattern = "WDFSetup.*\.exe$|Wise-Duplicate-Finder-Setup.*\.exe$"

New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

if (-not (Test-Path $ProgramExecutablePath)) {
    Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern
} else {
    Write-Log "$ProgramName is already installed." "INFO"
}