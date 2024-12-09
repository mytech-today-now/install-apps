# AngryIPScanner.ps1

$ProgramName = "Angry IP Scanner"
$ProgramExecutablePath = "C:\Program Files\Angry IP Scanner\ipscan.exe"
$DownloadsPageURL = "https://angryip.org/download/#windows"
$TempDir = "$env:TEMP\AngryIPScannerInstaller"
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
    Write-Log "Starting installation of $ProgramName" "INFO"
    try {
        Write-Log "Retrieving the latest download link from $DownloadsPageURL" "INFO"
        $htmlContent = Invoke-WebRequest -Uri $DownloadsPageURL -UseBasicParsing
        
        $installerLink = ($htmlContent.Links | Where-Object { $_.href -match "ipscan-.*-setup\.exe$" }).href | Select-Object -First 1

        if (-not $installerLink) {
            Write-Log "Error: Unable to find Angry IP Scanner installer." "ERROR"
            throw "Installer link not found."
        }

        if ($installerLink -notmatch "^https?://") {
            $uri = [System.Uri]$DownloadsPageURL
            $installerURL = [System.Uri]::new($uri, $installerLink).AbsoluteUri
        } else {
            $installerURL = $installerLink
        }

        Write-Log "Installer URL: $installerURL" "INFO"
        $installerPath = Join-Path $TempDir "angryip_installer.exe"
        Write-Log "Downloading installer to $installerPath" "INFO"
        Invoke-WebRequest -Uri $installerURL -OutFile $installerPath

        if (-not (Test-Path $installerPath)) {
            Write-Log "Error: download failed." "ERROR"
            throw "Installer download failed."
        }

        Write-Log "Starting silent installation" "INFO"
        $installProcess = Start-Process -FilePath $installerPath -ArgumentList "/verysilent", "/norestart" -Wait -PassThru

        if ($installProcess.ExitCode -ne 0) {
            Write-Log "Installation failed with exit code $($installProcess.ExitCode)." "ERROR"
            throw "Installation failed."
        }

        Write-Log "$ProgramName installed successfully." "INFO"
    } catch {
        Write-Log "Error: $_" "ERROR"
        throw $_
    } finally {
        Remove-Item $TempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

if (-not (IsInstalled)) {
    Install-Program
} else {
    Write-Log "$ProgramName is already installed." "INFO"
}