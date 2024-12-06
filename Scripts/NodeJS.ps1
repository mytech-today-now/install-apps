# NodeJS.ps1

$ProgramName = "Node.js"
$ProgramExecutablePath = "C:\Program Files\nodejs\node.exe"
$DownloadsPageURL = "https://nodejs.org/en/download/package-manager"
$TempDir = "$env:TEMP\NodeJSInstaller"
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

function IsInstalled {
    return Test-Path $ProgramExecutablePath
}

function Install-Program {
    Write-Log "Installing $ProgramName"
    try {
        Write-Log "Fetching installer link"
        $htmlContent = Invoke-WebRequest -Uri $DownloadsPageURL -UseBasicParsing

        # node-v.*-x64.msi (If we find MSI link)
        $installerLink = ($htmlContent.Links | Where-Object { $_.href -match "node-v.*-x64\.msi$" }).href | Select-Object -First 1

        if (-not $installerLink) {
            throw "No node.js installer found."
        }

        if ($installerLink -notmatch "^https?://") {
            $uri = [System.Uri]$DownloadsPageURL
            $installerURL = [System.Uri]::new($uri, $installerLink).AbsoluteUri
        } else {
            $installerURL = $installerLink
        }

        $installerPath = Join-Path $TempDir "nodejs_installer.msi"
        Invoke-WebRequest -Uri $installerURL -OutFile $installerPath

        if (-not (Test-Path $installerPath)) {
            throw "Download failed."
        }

        # MSI silent: msiexec /i <file> /qn /norestart
        Write-Log "Silent installation"
        $installProcess = Start-Process -FilePath "msiexec.exe" -ArgumentList "/i", "`"$installerPath`"", "/qn", "/norestart" -Wait -PassThru

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
