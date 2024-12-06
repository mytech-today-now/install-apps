# AngryIPScanner.ps1

$ProgramName = "Angry IP Scanner"
$ProgramExecutablePath = "C:\Program Files\Angry IP Scanner\ipscan.exe"
$DownloadsPageURL = "https://angryip.org/download/#windows"
$TempDir = "$env:TEMP\AngryIPScannerInstaller"
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

function IsInstalled {
    return Test-Path $ProgramExecutablePath
}

function Install-Program {
    Write-Log "Starting installation of $ProgramName"
    try {
        Write-Log "Retrieving the latest download link from $DownloadsPageURL"
        $htmlContent = Invoke-WebRequest -Uri $DownloadsPageURL -UseBasicParsing
        
        # ipscan-3.*-setup.exe or similar
        $installerLink = ($htmlContent.Links | Where-Object { $_.href -match "ipscan-.*-setup\.exe$" }).href | Select-Object -First 1

        if (-not $installerLink) {
            Write-Log "Error: Unable to find Angry IP Scanner installer."
            throw "Installer link not found."
        }

        if ($installerLink -notmatch "^https?://") {
            $uri = [System.Uri]$DownloadsPageURL
            $installerURL = [System.Uri]::new($uri, $installerLink).AbsoluteUri
        } else {
            $installerURL = $installerLink
        }

        Write-Log "Installer URL: $installerURL"
        $installerPath = Join-Path $TempDir "angryip_installer.exe"
        Write-Log "Downloading installer to $installerPath"
        Invoke-WebRequest -Uri $installerURL -OutFile $installerPath

        if (-not (Test-Path $installerPath)) {
            Write-Log "Error: download failed."
            throw "Installer download failed."
        }

        # Likely Inno Setup
        Write-Log "Starting silent installation"
        $installProcess = Start-Process -FilePath $installerPath -ArgumentList "/verysilent", "/norestart" -Wait -PassThru

        if ($installProcess.ExitCode -ne 0) {
            Write-Log "Installation failed with exit code $($installProcess.ExitCode)."
            throw "Installation failed."
        }

        Write-Log "$ProgramName installed successfully."

    } catch {
        Write-Log "Error: $_"
        throw $_
    } finally {
        Remove-Item $TempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}
