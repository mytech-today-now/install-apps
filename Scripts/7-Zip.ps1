# 7-Zip.ps1

$ProgramName = "7-Zip"
$ProgramExecutablePath = "C:\Program Files\7-Zip\7zFM.exe"
$DownloadsPageURL = "https://www.7-zip.org/download.html"
$TempDir = "$env:TEMP\7ZipInstaller"

# Set the path for the log file to be in the install-apps directory
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
    Test-Path $ProgramExecutablePath
}

function Install-Program {
    Write-Log "Starting installation of $ProgramName" "INFO"
    try {
        $html = Invoke-WebRequest -Uri $DownloadsPageURL -UseBasicParsing
        $installerLink = ($html.Links | Where-Object { $_.href -match "7z.*-x64\.exe$" }).href | Select-Object -First 1
        if (-not $installerLink) { 
            Write-Log "No installer link found on the downloads page." "ERROR"
            throw "No installer link found."
        }

        if ($installerLink -notmatch "^https?://") {
            $installerURL = [System.Uri]::new([System.Uri]$DownloadsPageURL, $installerLink).AbsoluteUri
        } else {
            $installerURL = $installerLink
        }

        $installerPath = Join-Path $TempDir "7zip_installer.exe"
        Write-Log "Downloading installer from $installerURL" "INFO"
        Invoke-WebRequest -Uri $installerURL -OutFile $installerPath

        Write-Log "Running silent installation" "INFO"
        $installProcess = Start-Process -FilePath $installerPath -ArgumentList "/S" -Wait -PassThru
        if ($installProcess.ExitCode -ne 0) { 
            Write-Log "Installation failed with exit code $($installProcess.ExitCode)" "ERROR"
            throw "Installation failed."
        }

        Write-Log "$ProgramName installed successfully." "INFO"
    } catch {
        Write-Log "Error during installation: $_" "ERROR"
        throw $_
    } finally {
        Write-Log "Cleaning up temporary files" "INFO"
        Remove-Item $TempDir -Recurse -Force
    }
}

# Example usage
if (-not (IsInstalled)) {
    Install-Program
} else {
    Write-Log "$ProgramName is already installed." "INFO"
}