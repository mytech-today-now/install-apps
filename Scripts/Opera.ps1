# Opera.ps1

$ProgramName = "Opera"
$ProgramExecutablePath = "C:\Program Files\Opera\opera.exe"
$DownloadsPageURL = "https://www.opera.com/download"
$TempDir = "$env:TEMP\OperaInstaller"
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

function IsInstalled {
    Test-Path $ProgramExecutablePath
}

function Install-Program {
    Write-Log "Installing $ProgramName"
    try {
        $html = Invoke-WebRequest -Uri $DownloadsPageURL -UseBasicParsing
        # OperaSetup.exe
        $installerLink = ($html.Links | Where-Object { $_.href -match "OperaSetup\.exe$" }).href | Select-Object -First 1
        if (-not $installerLink) { throw "No installer link found." }

        if ($installerLink -notmatch "^https?://") {
            $installerURL = [System.Uri]::new([System.Uri]$DownloadsPageURL, $installerLink).AbsoluteUri
        } else {
            $installerURL = $installerLink
        }

        $installerPath = Join-Path $TempDir "opera_installer.exe"
        Invoke-WebRequest -Uri $installerURL -OutFile $installerPath

        # Opera might support /silent /install
        Write-Log "Silent installation"
        $installProcess = Start-Process -FilePath $installerPath -ArgumentList "/silent","/install" -Wait -PassThru
        if ($installProcess.ExitCode -ne 0) { throw "Failed." }

        Write-Log "$ProgramName installed successfully."
    } catch {
        Write-Log "Error: $_"
        throw $_
    } finally {
        Remove-Item $TempDir -Recurse -Force
    }
}
