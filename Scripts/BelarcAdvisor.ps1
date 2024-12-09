# BelarcAdvisor.ps1

$ProgramName = "Belarc Advisor"
$ProgramExecutablePath = "C:\Program Files (x86)\Belarc\BelarcAdvisor\BelarcAdvisor.exe"
$DownloadsPageURL = "https://www.majorgeeks.com/files/details/belarc_advisor.html"
$TempDir = "$env:TEMP\BelarcAdvisorInstaller"
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
        Write-Log "Retrieving installer link from $DownloadsPageURL" "INFO"
        $htmlContent = Invoke-WebRequest -Uri $DownloadsPageURL -UseBasicParsing
        
        $installerLink = ($htmlContent.Links | Where-Object { $_.href -match "AdvisorInstaller.*\.exe$" }).href | Select-Object -First 1

        if (-not $installerLink) {
            Write-Log "Error: Unable to find Belarc Advisor installer." "ERROR"
            throw "Installer link not found."
        }

        if ($installerLink -notmatch "^https?://") {
            $uri = [System.Uri]$DownloadsPageURL
            $installerURL = [System.Uri]::new($uri, $installerLink).AbsoluteUri
        } else {
            $installerURL = $installerLink
        }

        $installerPath = Join-Path $TempDir "belarc_installer.exe"
        Write-Log "Downloading to $installerPath" "INFO"
        Invoke-WebRequest -Uri $installerURL -OutFile $installerPath

        if (-not (Test-Path $installerPath)) {
            Write-Log "Download failed." "ERROR"
            throw "Installer download failed."
        }

        Write-Log "Silent installation" "INFO"
        $installProcess = Start-Process -FilePath $installerPath -ArgumentList "/S" -Wait -PassThru

        if ($installProcess.ExitCode -ne 0) {
            Write-Log "Failed with exit code $($installProcess.ExitCode)." "ERROR"
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