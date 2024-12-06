# SignalMessenger.ps1

$ProgramName = "Signal"
$ProgramExecutablePath = "C:\Program Files\Signal\Signal.exe"

$DownloadsPageURL = "https://signal.org/download/"
$TempDir = "$env:TEMP\SignalInstaller"
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

function IsInstalled {
    return Test-Path $ProgramExecutablePath
}

function Install-Program {
    Write-Log "Starting installation of $ProgramName"
    try {
        Write-Log "Retrieving the latest download link from $DownloadsPageURL"
        
        $htmlContent = Invoke-WebRequest -Uri $DownloadsPageURL -UseBasicParsing
        $installerLink = ($htmlContent.Links | Where-Object { $_.href -match "SignalSetup\.exe$" }).href | Select-Object -First 1

        if (-not $installerLink) {
            Write-Log "Error: Unable to find the Signal installer link."
            throw "Installer link not found."
        }

        if ($installerLink -notmatch "^https?://") {
            $uri = [System.Uri]$DownloadsPageURL
            $installerURL = [System.Uri]::new($uri, $installerLink).AbsoluteUri
        } else {
            $installerURL = $installerLink
        }

        Write-Log "Latest installer URL: $installerURL"

        $installerPath = Join-Path $TempDir "signal_latest_installer.exe"
        Write-Log "Downloading installer to $installerPath"
        Invoke-WebRequest -Uri $installerURL -OutFile $installerPath
        
        if (-not (Test-Path $installerPath)) {
            Write-Log "Error: Installer download failed."
            throw "Installer download failed."
        }

        Write-Log "Starting silent installation"
        # Try "/silent" first. If not working, try "/S"
        $installProcess = Start-Process -FilePath $installerPath -ArgumentList "/silent" -Wait -PassThru

        if ($installProcess.ExitCode -ne 0) {
            Write-Log "Error: Installation failed with exit code $($installProcess.ExitCode). Trying '/S'..."
            # Try another silent argument if needed
            $installProcess = Start-Process -FilePath $installerPath -ArgumentList "/S" -Wait -PassThru
            if ($installProcess.ExitCode -ne 0) {
                Write-Log "Error: Installation still failed with exit code $($installProcess.ExitCode)."
                throw "Installation failed."
            }
        }

        Write-Log "$ProgramName installation completed successfully."
    } catch {
        Write-Log "Error during installation: $_"
        throw $_
    } finally {
        Write-Log "Cleaning up temporary files"
        Remove-Item $TempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}
