# OpenShotVideoEditor.ps1

$ProgramName = "OpenShot Video Editor"
$ProgramExecutablePath = "C:\Program Files\OpenShot Video Editor\openshot-qt.exe"
$DownloadsPageURL = "https://www.openshot.org/download/"
$TempDir = "$env:TEMP\OpenShotInstaller"
$LogFilePath = Join-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "..\") -ChildPath "installation.log"

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
    return Test-Path $ProgramExecutablePath
}

function Install-Program {
    Write-Log "Starting installation of $ProgramName"
    try {
        Write-Log "Retrieving the latest download link from $DownloadsPageURL"
        
        $htmlContent = Invoke-WebRequest -Uri $DownloadsPageURL -UseBasicParsing
        $installerLink = ($htmlContent.Links | Where-Object { $_.href -match "OpenShot-.*-Windows-x86_64\.exe$" }).href | Select-Object -First 1

        if (-not $installerLink) {
            Write-Log "Error: Unable to find the OpenShot installer link."
            throw "Installer link not found."
        }

        if ($installerLink -notmatch "^https?://") {
            $uri = [System.Uri]$DownloadsPageURL
            $installerURL = [System.Uri]::new($uri, $installerLink).AbsoluteUri
        } else {
            $installerURL = $installerLink
        }

        Write-Log "Latest installer URL: $installerURL"

        $installerPath = Join-Path $TempDir "openshot_latest_installer.exe"
        Write-Log "Downloading installer to $installerPath"
        Invoke-WebRequest -Uri $installerURL -OutFile $installerPath
        
        if (-not (Test-Path $installerPath)) {
            Write-Log "Error: Installer download failed."
            throw "Installer download failed."
        }

        Write-Log "Starting silent installation"
        $installProcess = Start-Process -FilePath $installerPath -ArgumentList "/verysilent", "/norestart" -Wait -PassThru

        if ($installProcess.ExitCode -ne 0) {
            Write-Log "Error: Installation failed with exit code $($installProcess.ExitCode)."
            throw "Installation failed."
        }
        
        Write-Log "$ProgramName installation completed successfully."
    } catch {
        Write-Log "Error during installation: $_"
        throw $_
    } finally {
        Write-Log "Cleaning up temporary files"
        Remove-Item $TempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

if (-not (IsInstalled)) {
    Install-Program
} else {
    Write-Log "$ProgramName is already installed." "INFO"
}