# Blender.ps1

# ==============================
# Program Information
# ==============================

$ProgramName = "Blender"
# Define the base path where Blender is installed
$BasePath = "C:\Program Files\Blender Foundation"

# Get all directories under the base path
$SubDirs = Get-ChildItem -Path $BasePath -Directory

# Iterate through each directory to find "blender.exe"
foreach ($Dir in $SubDirs) {
    $ExePath = Join-Path $Dir.FullName "blender.exe"
    if (Test-Path $ExePath) {
        $ProgramExecutablePath = $ExePath
        break
    }
}

# If no executable is found, $ProgramExecutablePath will remain unset
if (-not $ProgramExecutablePath) {
    Write-Host "No Blender executable found in $BasePath"
} else {
    Write-Host "Blender executable found at: $ProgramExecutablePath"
}

# The Blender downloads page
$DownloadsPageURL = "https://www.blender.org/download/"

# Temporary directory for downloads
$TempDir = "$env:TEMP\BlenderInstaller"
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

# ==============================
# Function to Check Installation
# ==============================

function IsInstalled {
    # Check if the Blender executable exists
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

        # Parse the HTML to find a Windows MSI installer link
        # We'll look for something matching 'blender-...-windows-x64.msi'
        $installerLink = ($htmlContent.Links | Where-Object {
            $_.href -match "blender-.*windows.*x64.*\.msi$"
        }).href | Select-Object -First 1

        if (-not $installerLink) {
            Write-Log "Error: Unable to find the latest Blender MSI installer link."
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
        $installerPath = Join-Path -Path $TempDir -ChildPath "blender_latest_installer.msi"
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
