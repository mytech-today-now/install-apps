# RenameIt.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "Rename-It!"
$ProgramExecutablePath = "C:\Program Files\Rename-It!\renameit.exe"
$DownloadsPageURL = "https://sourceforge.net/projects/renameit/files/latest/download"
$TempDir = "$env:TEMP\RenameItInstaller"
$InstallerPattern = "renameit_installer.exe"

New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

if (-not (Test-Path $ProgramExecutablePath)) {
    Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern
} else {
    Write-Log "$ProgramName is already installed." "INFO"
}