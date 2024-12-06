# CoreFTP.ps1

$ProgramName = "Core FTP"
$ProgramExecutablePath = "C:\Program Files\CoreFTP\coreftp.exe"
$DownloadsPageURL = "https://www.coreftp.com/download.html"
$TempDir = "$env:TEMP\CoreFTPInstaller"
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

function IsInstalled {
    return Test-Path $ProgramExecutablePath
}

function Install-Program {
    Write-Log "Installing $ProgramName"
    try {
        Write-Log "Retrieving installer from $DownloadsPageURL"
        $htmlContent = Invoke-WebRequest -Uri $DownloadsPageURL -UseBasicParsing
        
        # coreftplite64.exe or similar
        $installerLink = ($htmlContent.Links | Where-Object { $_.href -match "coreftp.*\.exe$" }).href | Select-Object -First 1

        if (-not $installerLink) {
            Write-Log "No installer found for Core FTP."
            throw "Installer link not found."
        }

        if ($installerLink -notmatch "^https?://") {
            $uri = [System.Uri]$DownloadsPageURL
            $installerURL = [System.Uri]::new($uri, $installerLink).AbsoluteUri
        } else {
            $installerURL = $installerLink
        }

        $installerPath = Join-Path $TempDir "coreftp_installer.exe"
        Invoke-WebRequest -Uri $installerURL -OutFile $installerPath

        if (-not (Test-Path $installerPath)) {
            Write-Log "Download failed."
            throw "Download failed."
        }

        Write-Log "Silent install"
        $installProcess = Start-Process -FilePath $installerPath -ArgumentList "/verysilent", "/norestart" -Wait -PassThru

        if ($installProcess.ExitCode -ne 0) {
            Write-Log "Installation failed with $($installProcess.ExitCode)."
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
