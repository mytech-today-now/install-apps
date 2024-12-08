# BitcoinCore.ps1

$ProgramName = "Bitcoin Core"
$ProgramExecutablePath = "C:\Program Files\Bitcoin\bitcoin-qt.exe"
$DownloadsPageURL = "https://bitcoin.org/en/download"
$TempDir = "$env:TEMP\BitcoinCoreInstaller"
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

function IsInstalled {
    Test-Path $ProgramExecutablePath
}

function Install-Program {
    Write-Log "Installing $ProgramName"
    try {
        $html = Invoke-WebRequest -Uri $DownloadsPageURL -UseBasicParsing
        # bitcoin-.*-win64-setup.exe
        $installerLink = ($html.Links | Where-Object { $_.href -match "bitcoin-.*-win64-setup\.exe$" }).href | Select-Object -First 1
        if (-not $installerLink) { throw "No installer link found." }

        if ($installerLink -notmatch "^https?://") {
            $installerURL = [System.Uri]::new([System.Uri]$DownloadsPageURL, $installerLink).AbsoluteUri
        } else {
            $installerURL = $installerLink
        }

        $installerPath = Join-Path $TempDir "bitcoin_core_installer.exe"
        Invoke-WebRequest -Uri $installerURL -OutFile $installerPath

        # Inno Setup
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
