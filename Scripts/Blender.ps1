# Blender.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "Blender"
$BasePath = "C:\Program Files\Blender Foundation"
$SubDirs = Get-ChildItem -Path $BasePath -Directory
$ProgramExecutablePath = $null

foreach ($Dir in $SubDirs) {
    $ExePath = Join-Path $Dir.FullName "blender.exe"
    if (Test-Path $ExePath) {
        $ProgramExecutablePath = $ExePath
        break
    }
}

$DownloadsPageURL = "https://www.blender.org/download/"
$TempDir = "$env:TEMP\BlenderInstaller"
$InstallerPattern = "blender-.*-windows64\.msi$"

Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern