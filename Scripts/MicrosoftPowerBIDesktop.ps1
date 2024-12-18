# MicrosoftPowerBIDesktop.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "Microsoft Power BI Desktop"
$ProgramExecutablePath = "C:\Users\kyle_\AppData\Local\Microsoft\WindowsApps\Microsoft.MicrosoftPowerBIDesktop_8wekyb3d8bbwe\PBIDesktopStore.exe"
$DownloadsPageURL = "https://www.microsoft.com/en-us/download/details.aspx?id=58494"
$TempDir = "$env:TEMP\PowerBIInstaller"
$InstallerPattern = "PBIDesktopSetup_x64\.exe$"

New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

if (-not (Test-Path $ProgramExecutablePath)) {
    Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern
} else {
    Write-Log "$ProgramName is already installed." "INFO"
}