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

if (-not $ProgramExecutablePath) {
    Write-Log "No Blender executable found in $BasePath" "ERROR"
} else {
    Write-Log "Blender executable found at: $ProgramExecutablePath" "INFO"
}

$DownloadsPageURL = "https://www.blender.org/download/"
$TempDir = "$env:TEMP\BlenderInstaller"
$InstallerPattern = "blender-.*-windows64\.msi$"

New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

if (-not (Test-Path $ProgramExecutablePath)) {
    Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern
} else {
    Write-Log "$ProgramName is already installed." "INFO"
}