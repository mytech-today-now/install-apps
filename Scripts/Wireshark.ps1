# Wireshark.ps1

$ProgramName = "Wireshark"
$ProgramExecutablePath = "C:\Program Files\Wireshark\Wireshark.exe"
$DownloadsPageURL = "https://www.wireshark.org/download.html"
$TempDir = "$env:TEMP\WiresharkInstaller"
$LogFilePath = Join-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "..\install-apps") -ChildPath "installation.log"

New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

function Write-Log {
    param (
        [string]$Message,
        [ValidateSet("INFO", "WARN", "ERROR")] [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp [$Level] $Message"
    Write-Output $logEntry
    Add-Content -Path $LogFilePath -Value $logEntry
}

function IsInstalled {
    Test-Path $ProgramExecutablePath
}

function Install-Program {
    Write-Log "Installing $ProgramName"
    try {
        $html = Invoke-WebRequest -Uri $DownloadsPageURL -UseBasicParsing
        $installerLink = ($html.Links | Where-Object { $_.href -match "Wireshark-win64-.*\.exe$" }).href | Select-Object -First 1
        if (-not $installerLink) { throw "No installer link found." }

        if ($installerLink -notmatch "^https?://") {
            $installerURL = [System.Uri]::new([System.Uri]$DownloadsPageURL, $installerLink).AbsoluteUri
        } else {
            $installerURL = $installerLink
        }

        $installerPath = Join-Path $TempDir "wireshark_installer.exe"
        Invoke-WebRequest -Uri $installerURL -OutFile $installerPath

        Write-Log "Silent installation"
        $installProcess = Start-Process -FilePath $installerPath -ArgumentList "/verysilent","/norestart" -Wait -PassThru
        if ($installProcess.ExitCode -ne 0) { throw "Failed." }

        Write-Log "$ProgramName installed successfully."
    } catch {
        Write-Log "Error: $_"
        throw $_
    } finally {
        Remove-Item $TempDir -Recurse -Force
    }
}

if (-not (IsInstalled)) {
    Install-Program
} else {
    Write-Log "$ProgramName is already installed." "INFO"
}