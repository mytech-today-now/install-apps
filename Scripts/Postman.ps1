# Postman.ps1

$ProgramName = "Postman"
$ProgramExecutablePath = "C:\Program Files\Postman\Postman.exe"
$DownloadsPageURL = "https://www.postman.com/downloads/"
$TempDir = "$env:TEMP\PostmanInstaller"
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

function IsInstalled {
    return Test-Path $ProgramExecutablePath
}

function Install-Program {
    Write-Log "Installing $ProgramName"
    try {
        Write-Log "Fetching installer link"
        $htmlContent = Invoke-WebRequest -Uri $DownloadsPageURL -UseBasicParsing

        # Postman-win64-setup.exe
        $installerLink = ($htmlContent.Links | Where-Object { $_.href -match "Postman-win64-setup\.exe$" }).href | Select-Object -First 1

        if (-not $installerLink) {
            throw "No Postman installer found."
        }

        if ($installerLink -notmatch "^https?://") {
            $uri = [System.Uri]$DownloadsPageURL
            $installerURL = [System.Uri]::new($uri, $installerLink).AbsoluteUri
        } else {
            $installerURL = $installerLink
        }

        $installerPath = Join-Path $TempDir "postman_installer.exe"
        Invoke-WebRequest -Uri $installerURL -OutFile $installerPath

        if (-not (Test-Path $installerPath)) {
            throw "Download failed."
        }

        # Try NSIS /S
        Write-Log "Silent installation"
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
