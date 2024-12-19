# InstantEyeDropper.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "Instant Eyedropper"
$ProgramExecutablePath = "C:\Program Files (x86)\InstantEyedropper\InstantEyedropper.exe"
$DownloadsPageURL = "http://instant-eyedropper.com/"
$TempDir = "$env:TEMP\InstantEyeDropperInstaller"
$InstallerPattern = "InstantEyedropper.*\.exe$"

Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern