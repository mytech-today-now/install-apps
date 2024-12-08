# Cursor.ps1

$ProgramName = "Cursor"
$ProgramExecutablePath = "C:\Program Files\Cursor\Cursor.exe"
$DownloadsPageURL = "https://www.cursor.com/"
$TempDir = "$env:TEMP\CursorInstaller"
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

function IsInstalled {
    Test-Path $ProgramExecutablePath
}

function Install-Program {
    Write-Log "Installing $ProgramName"
    try {
        $html = Invoke-WebRequest -Uri $DownloadsPageURL -UseBasicParsing
        # Cursor-.*-Setup.exe maybe
        $installerLink = ($html.Links | Where-Object { $_.href -match "Cursor-.*-Setup\.exe$" }).href | Select-Object -First 1
        if (-not $installerLink) { throw "No installer found." }

        if ($installerLink -notmatch "^https?://") {
            $installerURL = [System.Uri]::new([System.Uri]$DownloadsPageURL, $installerLink).AbsoluteUri
        } else {
            $installerURL = $installerLink
        }

        $installerPath = Join-Path $TempDir "cursor_installer.exe"
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
