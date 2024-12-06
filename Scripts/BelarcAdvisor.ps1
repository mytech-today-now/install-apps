# BelarcAdvisor.ps1

$ProgramName = "Belarc Advisor"
$ProgramExecutablePath = "C:\Program Files (x86)\Belarc\BelarcAdvisor\BelarcAdvisor.exe"
$DownloadsPageURL = "https://www.majorgeeks.com/files/details/belarc_advisor.html"
$TempDir = "$env:TEMP\BelarcAdvisorInstaller"
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

function IsInstalled {
    return Test-Path $ProgramExecutablePath
}

function Install-Program {
    Write-Log "Starting installation of $ProgramName"
    try {
        Write-Log "Retrieving installer link from $DownloadsPageURL"
        $htmlContent = Invoke-WebRequest -Uri $DownloadsPageURL -UseBasicParsing
        
        # Possibly BelarcAdvisorInstaller.exe
        $installerLink = ($htmlContent.Links | Where-Object { $_.href -match "AdvisorInstaller.*\.exe$" }).href | Select-Object -First 1

        if (-not $installerLink) {
            Write-Log "Error: Unable to find Belarc Advisor installer."
            throw "Installer link not found."
        }

        if ($installerLink -notmatch "^https?://") {
            $uri = [System.Uri]$DownloadsPageURL
            $installerURL = [System.Uri]::new($uri, $installerLink).AbsoluteUri
        } else {
            $installerURL = $installerLink
        }

        $installerPath = Join-Path $TempDir "belarc_installer.exe"
        Write-Log "Downloading to $installerPath"
        Invoke-WebRequest -Uri $installerURL -OutFile $installerPath

        if (-not (Test-Path $installerPath)) {
            Write-Log "Download failed."
            throw "Installer download failed."
        }

        # Try NSIS /S
        Write-Log "Silent installation"
        $installProcess = Start-Process -FilePath $installerPath -ArgumentList "/S" -Wait -PassThru

        if ($installProcess.ExitCode -ne 0) {
            Write-Log "Failed with exit code $($installProcess.ExitCode)."
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
