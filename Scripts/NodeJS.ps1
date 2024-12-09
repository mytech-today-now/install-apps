# NodeJS.ps1

$ProgramName = "Node.js"
$ProgramExecutablePath = "C:\Program Files\nodejs\node.exe"
$DownloadsPageURL = "https://nodejs.org/en/download/package-manager"
$TempDir = "$env:TEMP\NodeJSInstaller"
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
    Write-Log "Installing $ProgramName" "INFO"
    try {
        Write-Log "Fetching installer link" "INFO"
        $htmlContent = Invoke-WebRequest -Uri $DownloadsPageURL -UseBasicParsing

        $installerLink = ($htmlContent.Links | Where-Object { $_.href -match "node-v.*-x64\.msi$" }).href | Select-Object -First 1

        if (-not $installerLink) {
            Write-Log "No node.js installer found." "ERROR"
            throw "No node.js installer found."
        }

        if ($installerLink -notmatch "^https?://") {
            $uri = [System.Uri]$DownloadsPageURL
            $installerURL = [System.Uri]::new($uri, $installerLink).AbsoluteUri
        } else {
            $installerURL = $installerLink
        }

        $installerPath = Join-Path $TempDir "nodejs_installer.msi"
        Invoke-WebRequest -Uri $installerURL -OutFile $installerPath

        if (-not (Test-Path $installerPath)) {
            Write-Log "Download failed." "ERROR"
            throw "Download failed."
        }

        Write-Log "Silent installation" "INFO"
        $installProcess = Start-Process -FilePath "msiexec.exe" -ArgumentList "/i", "`"$installerPath`"", "/qn", "/norestart" -Wait -PassThru

        if ($installProcess.ExitCode -ne 0) {
            Write-Log "Installation failed." "ERROR"
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