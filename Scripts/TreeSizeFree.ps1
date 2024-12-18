# TreeSizeFree.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "TreeSize Free"
$ProgramExecutablePath = "C:\Program Files\JAM Software\TreeSize Free\TreeSizeFree.exe"
$DownloadsPageURL = "https://www.majorgeeks.com/files/details/treesize_free.html"
$TempDir = "$env:TEMP\TreeSizeFreeInstaller"
$InstallerPattern = "TreeSizeFreeSetup.*\.exe$"

New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

if (-not (Test-Path $ProgramExecutablePath)) {
    Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern
} else {
    Write-Log "$ProgramName is already installed." "INFO"
}