# Python.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "Python"
$ProgramExecutablePath = "C:\Program Files\Python\python.exe"
$DownloadsPageURL = "https://www.python.org/downloads/"
$TempDir = "$env:TEMP\PythonInstaller"
$InstallerPattern = "python-3.*-amd64\.exe$"

Install-Program -ProgramName $ProgramName -ProgramExecutablePath $ProgramExecutablePath -DownloadsPageURL $DownloadsPageURL -TempDir $TempDir -InstallerPattern $InstallerPattern