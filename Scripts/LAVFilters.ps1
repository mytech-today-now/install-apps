# LAVFilters.ps1

$ProgramName = "LAV Filters"
# Assume they install in C:\Program Files\LAV Filters\
$ProgramExecutablePath = "C:\Program Files (x86)\LAV Filters\unins000.exe"
$DownloadsPageURL = "https://github.com/Nevcairiel/LAVFilters/releases"
$TempDir = "$env:TEMP\LAVFiltersInstaller"
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

function IsInstalled {
    return Test-Path $ProgramExecutablePath
}

function Install-Program {
    Write-Log "Installing $ProgramName"
    try {
        Write-Log "Fetching installer link"
        $htmlContent = Invoke-WebRequest -Uri $DownloadsPageURL -UseBasicParsing

        # LAVFilters-.*-installer.exe
        $installerLink = ($htmlContent.Links | Where-Object { $_.href -match "LAVFilters-.*-installer\.exe$" }).href | Select-Object -First 1

        if (-not $installerLink) {
            throw "No LAV Filters installer found."
        }

        if ($installerLink -notmatch "^https?://") {
            $uri = [System.Uri]$DownloadsPageURL
            $installerURL = [System.Uri]::new($uri, $installerLink).AbsoluteUri
        } else {
            $installerURL = $installerLink
        }

        $installerPath = Join-Path $TempDir "lavfilters_installer.exe"
        Invoke-WebRequest -Uri $installerURL -OutFile $installerPath

        if (-not (Test-Path $installerPath)) {
            throw "Download failed."
        }

        # Inno Setup
        Write-Log "Silent installation"
        $installProcess = Start-Process -FilePath $installerPath -ArgumentList "/verysilent", "/norestart" -Wait -PassThru

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
