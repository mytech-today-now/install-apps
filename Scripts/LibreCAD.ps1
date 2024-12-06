# LibreCAD.ps1

$ProgramName = "LibreCAD"
$ProgramExecutablePath = "C:\Program Files\LibreCAD\LibreCAD.exe"
$DownloadsPageURL = "https://librecad.org/#download"
$TempDir = "$env:TEMP\LibreCADInstaller"
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

function IsInstalled {
    return Test-Path $ProgramExecutablePath
}

function Install-Program {
    Write-Log "Starting installation of $ProgramName"
    try {
        Write-Log "Retrieving the latest download link from $DownloadsPageURL"
        $htmlContent = Invoke-WebRequest -Uri $DownloadsPageURL -UseBasicParsing

        # Look for something like LibreCAD-.*-installer.exe
        $installerLink = ($htmlContent.Links | Where-Object { $_.href -match "LibreCAD-.*-installer\.exe$" }).href | Select-Object -First 1

        if (-not $installerLink) {
            Write-Log "Error: Unable to find the LibreCAD installer link."
            throw "Installer link not found."
        }

        if ($installerLink -notmatch "^https?://") {
            $uri = [System.Uri]$DownloadsPageURL
            $installerURL = [System.Uri]::new($uri, $installerLink).AbsoluteUri
        } else {
            $installerURL = $installerLink
        }

        Write-Log "Latest installer URL: $installerURL"
        $installerPath = Join-Path $TempDir "librecad_installer.exe"
        Write-Log "Downloading installer to $installerPath"
        Invoke-WebRequest -Uri $installerURL -OutFile $installerPath

        if (-not (Test-Path $installerPath)) {
            Write-Log "Error: Installer download failed."
            throw "Installer download failed."
        }

        # Inno Setup silent
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
        Remove-Item $TempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

