# MicrosoftPowerBIDesktop.ps1

$ProgramName = "Microsoft Power BI Desktop"
$ProgramExecutablePath = "C:\Users\kyle_\AppData\Local\Microsoft\WindowsApps\Microsoft.MicrosoftPowerBIDesktop_8wekyb3d8bbwe\PBIDesktopStore.exe"
$DownloadsPageURL = "https://www.microsoft.com/en-us/download/details.aspx?id=58494"
$TempDir = "$env:TEMP\PowerBIInstaller"
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

function IsInstalled {
    return Test-Path $ProgramExecutablePath
}

function Install-Program {
    Write-Log "Starting installation of $ProgramName"
    try {
        Write-Log "Retrieving the installer link from $DownloadsPageURL"
        $htmlContent = Invoke-WebRequest -Uri $DownloadsPageURL -UseBasicParsing

        # Look for PBIDesktopSetup_x64.exe or similar
        $installerLink = ($htmlContent.Links | Where-Object { $_.href -match "PBIDesktopSetup_x64\.exe$" }).href | Select-Object -First 1

        if (-not $installerLink) {
            Write-Log "Error: Unable to find the Power BI Desktop installer link."
            throw "Installer link not found."
        }

        if ($installerLink -notmatch "^https?://") {
            $uri = [System.Uri]$DownloadsPageURL
            $installerURL = [System.Uri]::new($uri, $installerLink).AbsoluteUri
        } else {
            $installerURL = $installerLink
        }

        Write-Log "Latest installer URL: $installerURL"
        $installerPath = Join-Path $TempDir "PBIDesktopSetup_x64.exe"
        Write-Log "Downloading installer to $installerPath"
        Invoke-WebRequest -Uri $installerURL -OutFile $installerPath

        if (-not (Test-Path $installerPath)) {
            Write-Log "Error: Installer download failed."
            throw "Installer download failed."
        }

        # Silent installation for MS installers often /quiet /norestart
        Write-Log "Starting silent installation"
        $installProcess = Start-Process -FilePath $installerPath -ArgumentList "/quiet", "/norestart" -Wait -PassThru

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
