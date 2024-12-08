# Thunderbird.ps1

$ProgramName = "Thunderbird"
$ProgramExecutablePath = "C:\Program Files\Mozilla Thunderbird\thunderbird.exe"
$DownloadsPageURL = "https://www.thunderbird.net/en-US/download/"
$TempDir = "$env:TEMP\ThunderbirdInstaller"
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

function IsInstalled {
    Test-Path $ProgramExecutablePath
}

function Install-Program {
    Write-Log "Installing $ProgramName"
    try {
        $html = Invoke-WebRequest -Uri $DownloadsPageURL -UseBasicParsing
        # Look for something like Thunderbird Setup .*\.exe
        $installerLink = ($html.Links | Where-Object { $_.href -match "Thunderbird%20Setup.*\.exe$" }).href | Select-Object -First 1
        if (-not $installerLink) {
            Write-Log "No installer link found for Thunderbird."
            throw "Installer link not found."
        }

        if ($installerLink -notmatch "^https?://") {
            $installerURL = [System.Uri]::new([System.Uri]$DownloadsPageURL, $installerLink).AbsoluteUri
        } else {
            $installerURL = $installerLink
        }

        $installerPath = Join-Path $TempDir "thunderbird_installer.exe"
        Invoke-WebRequest -Uri $installerURL -OutFile $installerPath

        Write-Log "Silent installation"
        # Thunderbird (NSIS-based) often supports /S
        $installProcess = Start-Process -FilePath $installerPath -ArgumentList "/S" -Wait -PassThru
        if ($installProcess.ExitCode -ne 0) {
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
