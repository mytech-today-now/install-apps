# LAVFilters.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "LAV Filters"
$ProgramExecutablePath = "C:\Program Files (x86)\LAV Filters\unins000.exe"
$DownloadsPageURL = "https://github.com/Nevcairiel/LAVFilters/releases"
$TempDir = "$env:TEMP\LAVFiltersInstaller"
$InstallerPattern = "LAVFilters-.*-installer\.exe$"

New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

if (-not (Test-Path $ProgramExecutablePath)) {
    Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern
} else {
    Write-Log "$ProgramName is already installed." "INFO"
}