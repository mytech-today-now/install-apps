# ClownfishVoiceChanger.ps1

$ProgramName = "Clownfish Voice Changer"
$ProgramExecutablePath = "C:\Program Files (x86)\ClownfishVoiceChanger\ClownfishVoiceChanger.exe"
$DownloadsPageURL = "https://clownfish-translator.com/voicechanger/download.html"
$TempDir = "$env:TEMP\ClownfishInstaller"
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

function IsInstalled {
    Test-Path $ProgramExecutablePath
}

function Install-Program {
    Write-Log "Installing $ProgramName"
    try {
        $html = Invoke-WebRequest -Uri $DownloadsPageURL -UseBasicParsing
        # ClownfishVoiceChanger.*.exe
        $installerLink = ($html.Links | Where-Object { $_.href -match "ClownfishVoiceChanger.*\.exe$" }).href | Select-Object -First 1
        if (-not $installerLink) { throw "No installer found." }

        if ($installerLink -notmatch "^https?://") {
            $installerURL = [System.Uri]::new([System.Uri]$DownloadsPageURL, $installerLink).AbsoluteUri
        } else {
            $installerURL = $installerLink
        }

        $installerPath = Join-Path $TempDir "clownfish_installer.exe"
        Invoke-WebRequest -Uri $installerURL -OutFile $installerPath

        Write-Log "Silent installation"
        # NSIS /S
        $installProcess = Start-Process -FilePath $installerPath -ArgumentList "/S" -Wait -PassThru
        if ($installProcess.ExitCode -ne 0) { throw "Failed." }

        Write-Log "$ProgramName installed successfully."
    } catch {
        Write-Log "Error: $_"
        throw $_
    } finally {
        Remove-Item $TempDir -Recurse -Force
    }
}
