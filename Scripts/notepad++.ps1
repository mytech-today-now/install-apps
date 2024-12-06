# NotePadPlusPlus.ps1

# ==============================
# Program Information
# ==============================

# Display name of the program
$ProgramName = "Notepad++"

# Path to the program's executable after installation
$ProgramExecutablePath = "C:\Program Files\Notepad++\notepad++.exe"

# URL of the Notepad++ downloads page
$DownloadsPageURL = "https://notepad-plus-plus.org/downloads/"

# Temporary directory for downloads
$TempDir = "$env:TEMP\NotepadPlusPlusInstaller"
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

# ==============================
# Function to Check Installation
# ==============================

function IsInstalled {
    # Check if the Notepad++ executable exists
    return Test-Path $ProgramExecutablePath
}

# ==============================
# Function to Install the Program
# ==============================

function Install-Program {
    Write-Log "Starting installation of $ProgramName"

    # Download the latest Notepad++ installer
    try {
        Write-Log "Retrieving the latest download link from $DownloadsPageURL"

        # Get the HTML content of the downloads page
        $htmlContent = Invoke-WebRequest -Uri $DownloadsPageURL -UseBasicParsing

        # Parse the HTML to find the latest installer URL
        # Look for the first occurrence of the 64-bit installer link (.exe)
        $installerLink = ($htmlContent.Links | Where-Object {
            $_.href -match "/releases/latest/download/npp\w+_Installer\.exe$"
        }).href

        if (-not $installerLink) {
            Write-Log "Error: Unable to find the latest installer link."
            throw "Installer link not found."
        }

        # Construct the full URL
        $installerURL = "https://github.com$installerLink"
        Write-Log "Latest installer URL: $installerURL"

        # Download the installer
        $installerPath = Join-Path -Path $TempDir -ChildPath "npp_latest_installer.exe"
        Write-Log "Downloading installer to $installerPath"
        Invoke-WebRequest -Uri $installerURL -OutFile $installerPath

        # Verify that the installer was downloaded
        if (-not (Test-Path $installerPath)) {
            Write-Log "Error: Installer download failed."
            throw "Installer download failed."
        }

        # Perform a silent installation
        Write-Log "Starting silent installation"
        $installProcess = Start-Process -FilePath $installerPath -ArgumentList "/S" -Wait -PassThru

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
