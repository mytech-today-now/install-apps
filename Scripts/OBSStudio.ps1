# OBSStudio.ps1

$ProgramName = "OBS Studio"
$ProgramExecutablePath = "C:\Program Files\obs-studio\bin\64bit\obs64.exe"
$DownloadsPageURL = "https://obsproject.com/"
$TempDir = "$env:TEMP\OBSStudioInstaller"
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

function IsInstalled {
    Test-Path $ProgramExecutablePath
}

function Install-Program {
    Write-Log "Installing $ProgramName"
    try {
        $html = Invoke-WebRequest -Uri $DownloadsPageURL -UseBasicParsing
        # OBS-Studio-.*-Full-Installer-x64.exe
        $installerLink = ($html.Links | Where-Object { $_.href -match "OBS-Studio-.*-Full-Installer-x64\.exe$" }).href | Select-Object -First 1
        if (-not $installerLink) { throw "No installer link found." }

        if ($installerLink -notmatch "^https?://") {
            $installerURL = [System.Uri]::new([System.Uri]$DownloadsPageURL, $installerLink).AbsoluteUri
        } else {
            $installerURL = $installerLink
        }

        $installerPath = Join-Path $TempDir "obs_installer.exe"
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
