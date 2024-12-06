# Telegram.ps1

$ProgramName = "Telegram"
$ProgramExecutablePath = "C:\Program Files\Telegram Desktop\Telegram.exe"
$DownloadsPageURL = "https://desktop.telegram.org/"
$TempDir = "$env:TEMP\TelegramInstaller"
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

function IsInstalled {
    return Test-Path $ProgramExecutablePath
}

function Install-Program {
    Write-Log "Installing $ProgramName"
    try {
        Write-Log "Fetching installer link"
        $htmlContent = Invoke-WebRequest -Uri $DownloadsPageURL -UseBasicParsing

        # tsetup.*.exe
        $installerLink = ($htmlContent.Links | Where-Object { $_.href -match "tsetup.*\.exe$" }).href | Select-Object -First 1

        if (-not $installerLink) {
            throw "No installer link found."
        }

        if ($installerLink -notmatch "^https?://") {
            $uri = [System.Uri]$DownloadsPageURL
            $installerURL = [System.Uri]::new($uri, $installerLink).AbsoluteUri
        } else {
            $installerURL = $installerLink
        }

        $installerPath = Join-Path $TempDir "telegram_installer.exe"
        Invoke-WebRequest -Uri $installerURL -OutFile $installerPath

        if (-not (Test-Path $installerPath)) {
            throw "Download failed."
        }

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
