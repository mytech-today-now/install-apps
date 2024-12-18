# Opera.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "Opera"
$ProgramExecutablePath = "C:\Program Files\Opera\opera.exe"
$DownloadsPageURL = "https://www.opera.com/computer/thanks?ni=stable&os=windows"
$TempDir = "$env:TEMP\OperaInstaller"
$InstallerPattern = "OperaSetup\.exe$"

New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

if (-not (Test-Path $ProgramExecutablePath)) {
    Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern
} else {
    Write-Log "$ProgramName is already installed." "INFO"
}