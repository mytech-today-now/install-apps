# 7-Zip.ps1

$ProgramName = "7-Zip"
$ProgramExecutablePath = "C:\Program Files\7-Zip\7zFM.exe"
$DownloadsPageURL = "https://www.7-zip.org/download.html"
$TempDir = "$env:TEMP\7ZipInstaller"
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

function IsInstalled {
    Test-Path $ProgramExecutablePath
}

function Install-Program {
    Write-Log "Installing $ProgramName"
    try {
        $html = Invoke-WebRequest -Uri $DownloadsPageURL -UseBasicParsing
        # 7z.*-x64.exe
        $installerLink = ($html.Links | Where-Object { $_.href -match "7z.*-x64\.exe$" }).href | Select-Object -First 1
        if (-not $installerLink) { throw "No installer link found." }

        if ($installerLink -notmatch "^https?://") {
            $installerURL = [System.Uri]::new([System.Uri]$DownloadsPageURL, $installerLink).AbsoluteUri
        } else {
            $installerURL = $installerLink
        }

        $installerPath = Join-Path $TempDir "7zip_installer.exe"
        Invoke-WebRequest -Uri $installerURL -OutFile $installerPath

        # 7-Zip supports /S for silent
        Write-Log "Silent installation"
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
