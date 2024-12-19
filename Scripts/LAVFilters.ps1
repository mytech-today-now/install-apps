# LAVFilters.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "LAV Filters"
$ProgramExecutablePath = "C:\Program Files (x86)\LAV Filters\unins000.exe"
$DownloadsPageURL = "https://github.com/Nevcairiel/LAVFilters/releases"
$TempDir = "$env:TEMP\LAVFiltersInstaller"
$InstallerPattern = "LAVFilters-.*-installer\.exe$"

Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern