# LibreOffice.ps1

# ==============================
# Program Information
# ==============================

$ProgramName = "LibreOffice"
$ProgramExecutablePath = "C:\Program Files\LibreOffice\program\soffice.exe"

# LibreOffice download page
$DownloadsPageURL = "https://www.libreoffice.org/download/download-libreoffice/"

# Temporary directory for downloads
$TempDir = "$env:TEMP\LibreOfficeInstaller"
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

# ==============================
# Function to Check Installation
# ==============================

function IsInstalled {
    # Check if the LibreOffice executable exists
    return Test-Path $ProgramExecutablePath
}

# ==============================
# Function to Install the Program
# ==============================

function Install-Program {
    Write-Log "Starting installation of $ProgramName"

    try {
        Write-Log "Retrieving the latest download link from $DownloadsPageURL"
        
        # Get the HTML content of the downloads page
        $htmlContent = Invoke-WebRequest -Uri $DownloadsPageURL -UseBasicParsing
        
        # Parse the HTML to find the latest Windows x64 MSI installer link.
        # Typical pattern: LibreOffice_7.6.2_Win_x64.msi
        # We'll match something like: LibreOffice_..._Win_x64.msi
        $installerLink = ($htmlContent.Links | Where-Object {
            $_.href -match "LibreOffice_.*_Win_x64\.msi$"
        }).href | Select-Object -First 1

        if (-not $installerLink) {
            Write-Log "Error: Unable to find the latest LibreOffice MSI installer link."
            throw "Installer link not found."
        }

        # Construct the full URL if it's relative
        if ($installerLink -notmatch "^https?://") {
            $uri = [System.Uri]$DownloadsPageURL
            $installerURL = [System.Uri]::new($uri, $installerLink).AbsoluteUri
        } else {
            $installerURL = $installerLink
        }

        Write-Log "Latest installer URL: $installerURL"

        # Download the installer
        $installerPath = Join-Path -Path $TempDir -ChildPath "libreoffice_latest_installer.msi"
        Write-Log "Downloading installer to $installerPath"
        Invoke-WebRequest -Uri $installerURL -OutFile $installerPath

        # Verify that the installer was downloaded
        if (-not (Test-Path $installerPath)) {
            Write-Log "Error: Installer download failed."
            throw "Installer download failed."
        }

        # Perform a silent installation using msiexec
        Write-Log "Starting silent installation via msiexec"
        $installProcess = Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$installerPath`" /qn /norestart" -Wait -PassThru

        if ($installProcess.ExitCode -ne 0) {
            Write-Log "Error: Installation failed with exit code $($installProcess.ExitCode)."
            throw "Installation failed."
        }

        Write-Log "$ProgramName installation completed successfully."

    } catch {
        Write-Log "Error during installation: $_"
        throw $_
    } finally {
        # Clean up the temporary files
        Write-Log "Cleaning up temporary files"
        Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# ==============================
# End of Script
# ==============================
