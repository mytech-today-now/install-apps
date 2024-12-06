# InstantEyeDropper.ps1

# ==============================
# Program Information
# ==============================

$ProgramName = "Instant Eyedropper"
$ProgramExecutablePath = "C:\Program Files (x86)\InstantEyedropper\InstantEyedropper.exe"

# URL of the Instant Eyedropper homepage
$DownloadsPageURL = "http://instant-eyedropper.com/"

# Temporary directory for downloads
$TempDir = "$env:TEMP\InstantEyeDropperInstaller"
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

# ==============================
# Function to Check Installation
# ==============================

function IsInstalled {
    # Check if the Instant Eyedropper executable exists
    return Test-Path $ProgramExecutablePath
}

# ==============================
# Function to Install the Program
# ==============================

function Install-Program {
    Write-Log "Starting installation of $ProgramName"

    try {
        Write-Log "Retrieving the latest download link from $DownloadsPageURL"

        # Get the HTML content of the download page
        $htmlContent = Invoke-WebRequest -Uri $DownloadsPageURL -UseBasicParsing

        # Parse the HTML to find the .exe installer link
        # The installer is likely named 'InstantEyedropperSetup.exe'
        $installerLink = ($htmlContent.Links | Where-Object {
            $_.href -match "InstantEyedropperSetup\.exe$"
        }).href | Select-Object -First 1

        if (-not $installerLink) {
            Write-Log "Error: Unable to find the Instant Eyedropper installer link."
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

        # Download the installer
        $installerPath = Join-Path -Path $TempDir -ChildPath "instant_eyedropper_setup.exe"
        Write-Log "Downloading installer to $installerPath"
        Invoke-WebRequest -Uri $installerURL -OutFile $installerPath

        # Verify that the installer was downloaded
        if (-not (Test-Path $installerPath)) {
            Write-Log "Error: Installer download failed."
            throw "Installer download failed."
        }

        # Attempt a silent installation (assuming NSIS installer, commonly "/S" works)
        Write-Log "Starting silent installation"
        $installProcess = Start-Process -FilePath $installerPath -ArgumentList "/S" -Wait -PassThru

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
