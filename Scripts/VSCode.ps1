# VSCode.ps1

# ==============================
# Program Information
# ==============================

$ProgramName = "Visual Studio Code"
$ProgramExecutablePath = "C:\Program Files\Microsoft VS Code\Code.exe"

# VSCode download page
$DownloadsPageURL = "https://code.visualstudio.com/download"

# Temporary directory for downloads
$TempDir = "$env:TEMP\VSCodeInstaller"
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

# ==============================
# Function to Check Installation
# ==============================

function IsInstalled {
    return Test-Path $ProgramExecutablePath
}

# ==============================
# Function to Install the Program
# ==============================

function Install-Program {
    Write-Log "Starting installation of $ProgramName"

    try {
        Write-Log "Retrieving the latest download link from $DownloadsPageURL"

        $htmlContent = Invoke-WebRequest -Uri $DownloadsPageURL -UseBasicParsing

        # Look for a Windows system installer link (e.g., VSCodeSetup-x64-<version>.exe)
        $installerLink = ($htmlContent.Links | Where-Object {
            $_.href -match "VSCodeSetup.*win32-x64.*\.exe$"
        }).href | Select-Object -First 1

        if (-not $installerLink) {
            Write-Log "Error: Unable to find the VSCode installer link."
            throw "Installer link not found."
        }

        # Construct the full URL if necessary
        if ($installerLink -notmatch "^https?://") {
            $uri = [System.Uri]$DownloadsPageURL
            $installerURL = [System.Uri]::new($uri, $installerLink).AbsoluteUri
        } else {
            $installerURL = $installerLink
        }

        Write-Log "Latest installer URL: $installerURL"

        $installerPath = Join-Path -Path $TempDir -ChildPath "vscode_latest_installer.exe"
        Write-Log "Downloading installer to $installerPath"
        Invoke-WebRequest -Uri $installerURL -OutFile $installerPath

        if (-not (Test-Path $installerPath)) {
            Write-Log "Error: Installer download failed."
            throw "Installer download failed."
        }

        # Silent installation (Inno Setup style)
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
        Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}
