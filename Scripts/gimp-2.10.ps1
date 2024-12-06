# Gimp.ps1

# ==============================
# Program Information
# ==============================

# Display name of the program
$ProgramName = "GIMP-2_is1"

# Path to the program's executable after installation
$ProgramExecutablePath = "C:\Program Files\GIMP 2\bin\gimp-2.10.exe"

# URL of the GIMP downloads page
$DownloadsPageURL = "https://www.gimp.org/downloads/"

# Temporary directory for downloads
$TempDir = "$env:TEMP\GIMPInstaller"
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

# ==============================
# Function to Check Installation
# ==============================

function IsInstalled {
    # Check if the GIMP executable exists
    return Test-Path $ProgramExecutablePath
}

# ==============================
# Function to Install the Program
# ==============================

function Install-Program {
    Write-Log "Starting installation of $ProgramName"

    # Download the latest GIMP installer
    try {
        Write-Log "Retrieving the latest download link from $DownloadsPageURL"

        # Get the HTML content of the downloads page
        $htmlContent = Invoke-WebRequest -Uri $DownloadsPageURL -UseBasicParsing

        # Parse the HTML to find the Windows installer link
        # Look for the link matching the GIMP Windows installer pattern
        $installerLink = ($htmlContent.Links | Where-Object {
            $_.href -match "/gimp/v[\d\.]+/windows/gimp-[\d\.]+-setup\.exe$"
        }).href | Select-Object -First 1

        if (-not $installerLink) {
            Write-Log "Error: Unable to find the latest installer link."
            throw "Installer link not found."
        }

        # Construct the full URL if necessary
        if ($installerLink -notmatch "^https?://") {
            $uri = New-Object System.Uri($DownloadsPageURL)
            $installerURL = [System.Uri]::new($uri, $installerLink).AbsoluteUri
        } else {
            $installerURL = $installerLink
        }

        Write-Log "Latest installer URL: $installerURL"

        # Download the installer
        $installerPath = Join-Path -Path $TempDir -ChildPath "gimp_latest_installer.exe"
        Write-Log "Downloading installer to $installerPath"
        Invoke-WebRequest -Uri $installerURL -OutFile $installerPath

        # Verify that the installer was downloaded
        if (-not (Test-Path $installerPath)) {
            Write-Log "Error: Installer download failed."
            throw "Installer download failed."
        }

        # Perform a silent installation
        Write-Log "Starting silent installation"
        $installProcess = Start-Process -FilePath $installerPath -ArgumentList "/VERYSILENT", "/NORESTART" -Wait -PassThru

        if ($installProcess.ExitCode -ne 0) {
            Write-Log "Error: Installation failed with exit code $($installProcess.ExitCode)."
            throw "Installation failed."
        }

        Write-Log "$ProgramName installation completed successfully"

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
