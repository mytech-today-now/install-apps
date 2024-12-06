# GIT.ps1

$ProgramName = "GIT"
$ProgramExecutablePath = "C:\Program Files\Git\bin\git.exe"
$DownloadsPageURL = "https://git-scm.com/downloads"
$TempDir = "$env:TEMP\GitInstaller"
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

function IsInstalled {
    return Test-Path $ProgramExecutablePath
}

function Install-Program {
    Write-Log "Installing $ProgramName"
    try {
        Write-Log "Retrieving installer link from $DownloadsPageURL"
        $htmlContent = Invoke-WebRequest -Uri $DownloadsPageURL -UseBasicParsing

        # Git-2.*-64-bit.exe
        $installerLink = ($htmlContent.Links | Where-Object { $_.href -match "Git-2.*-64-bit\.exe$" }).href | Select-Object -First 1

        if (-not $installerLink) {
            Write-Log "Git installer not found."
            throw "Installer link not found."
        }

        if ($installerLink -notmatch "^https?://") {
            $uri = [System.Uri]$DownloadsPageURL
            $installerURL = [System.Uri]::new($uri, $installerLink).AbsoluteUri
        } else {
            $installerURL = $installerLink
        }

        $installerPath = Join-Path $TempDir "git_installer.exe"
        Invoke-WebRequest -Uri $installerURL -OutFile $installerPath

        if (-not (Test-Path $installerPath)) {
            throw "Download failed."
        }

        Write-Log "Silent install"
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
