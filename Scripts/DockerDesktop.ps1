# DockerDesktop.ps1

$ProgramName = "Docker Desktop"
$ProgramExecutablePath = "C:\Program Files\Docker\Docker\Docker Desktop.exe"
$DownloadsPageURL = "https://www.docker.com/products/docker-desktop/"
$TempDir = "$env:TEMP\DockerDesktopInstaller"
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

function IsInstalled {
    return Test-Path $ProgramExecutablePath
}

function Install-Program {
    Write-Log "Starting installation of $ProgramName"
    try {
        Write-Log "Retrieving the installer link from $DownloadsPageURL"
        $htmlContent = Invoke-WebRequest -Uri $DownloadsPageURL -UseBasicParsing
        
        # Look for Docker Desktop Installer.exe
        $installerLink = ($htmlContent.Links | Where-Object { $_.href -match "Docker Desktop Installer.*\.exe$" }).href | Select-Object -First 1

        if (-not $installerLink) {
            # If unable to parse, consider a known stable link or official docs
            Write-Log "Error: Unable to find Docker Desktop installer link."
            throw "Installer link not found."
        }

        if ($installerLink -notmatch "^https?://") {
            $uri = [System.Uri]$DownloadsPageURL
            $installerURL = [System.Uri]::new($uri, $installerLink).AbsoluteUri
        } else {
            $installerURL = $installerLink
        }

        Write-Log "Latest installer URL: $installerURL"
        $installerPath = Join-Path $TempDir "dockerdesktop_installer.exe"
        Write-Log "Downloading installer to $installerPath"
        Invoke-WebRequest -Uri $installerURL -OutFile $installerPath

        if (-not (Test-Path $installerPath)) {
            Write-Log "Error: Installer download failed."
            throw "Installer download failed."
        }

        # Docker Desktop silent: "install --quiet"
        Write-Log "Starting silent installation"
        $installProcess = Start-Process -FilePath $installerPath -ArgumentList "install", "--quiet" -Wait -PassThru

        if ($installProcess.ExitCode -ne 0) {
            Write-Log "Error: Installation failed with exit code $($installProcess.ExitCode)."
            throw "Installation failed."
        }

        Write-Log "$ProgramName installation completed successfully."

    } catch {
        Write-Log "Error: $_"
        throw $_
    } finally {
        Write-Log "Cleaning up temporary files"
        Remove-Item $TempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}
