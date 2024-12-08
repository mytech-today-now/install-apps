# Wireshark.ps1

$ProgramName = "Wireshark"
$ProgramExecutablePath = "C:\Program Files\Wireshark\Wireshark.exe"
$DownloadsPageURL = "https://www.wireshark.org/download.html"
$TempDir = "$env:TEMP\WiresharkInstaller"
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

function IsInstalled {
    Test-Path $ProgramExecutablePath
}

function Install-Program {
    Write-Log "Installing $ProgramName"
    try {
        $html = Invoke-WebRequest -Uri $DownloadsPageURL -UseBasicParsing
        # Wireshark-win64-.*.exe
        $installerLink = ($html.Links | Where-Object { $_.href -match "Wireshark-win64-.*\.exe$" }).href | Select-Object -First 1
        if (-not $installerLink) { throw "No installer link found." }

        if ($installerLink -notmatch "^https?://") {
            $installerURL = [System.Uri]::new([System.Uri]$DownloadsPageURL, $installerLink).AbsoluteUri
        } else {
            $installerURL = $installerLink
        }

        $installerPath = Join-Path $TempDir "wireshark_installer.exe"
        Invoke-WebRequest -Uri $installerURL -OutFile $installerPath

        # Wireshark uses NSIS or Inno Setup: try /S or /verysilent
        Write-Log "Silent installation"
        $installProcess = Start-Process -FilePath $installerPath -ArgumentList "/verysilent","/norestart" -Wait -PassThru
        if ($installProcess.ExitCode -ne 0) { throw "Failed." }

        Write-Log "$ProgramName installed successfully."
    } catch {
        Write-Log "Error: $_"
        throw $_
    } finally {
        Remove-Item $TempDir -Recurse -Force
    }
}
