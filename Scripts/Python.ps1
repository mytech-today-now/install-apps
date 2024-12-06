# Python.ps1

$ProgramName = "Python"
$ProgramExecutablePath = "C:\Program Files\Python\python.exe"
$DownloadsPageURL = "https://www.python.org/downloads/"
$TempDir = "$env:TEMP\PythonInstaller"
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

function IsInstalled {
    return Test-Path $ProgramExecutablePath
}

function Install-Program {
    Write-Log "Installing $ProgramName"
    try {
        Write-Log "Fetching installer link"
        $htmlContent = Invoke-WebRequest -Uri $DownloadsPageURL -UseBasicParsing

        # python-3.*-amd64.exe
        $installerLink = ($htmlContent.Links | Where-Object { $_.href -match "python-3.*-amd64\.exe$" }).href | Select-Object -First 1

        if (-not $installerLink) {
            throw "No installer link found."
        }

        if ($installerLink -notmatch "^https?://") {
            $uri = [System.Uri]$DownloadsPageURL
            $installerURL = [System.Uri]::new($uri, $installerLink).AbsoluteUri
        } else {
            $installerURL = $installerLink
        }

        $installerPath = Join-Path $TempDir "python_installer.exe"
        Invoke-WebRequest -Uri $installerURL -OutFile $installerPath

        if (-not (Test-Path $installerPath)) {
            throw "Download failed."
        }

        # Python silent install: /quiet InstallAllUsers=1 PrependPath=1
        Write-Log "Silent installation"
        $installProcess = Start-Process -FilePath $installerPath -ArgumentList "/quiet", "InstallAllUsers=1", "PrependPath=1" -Wait -PassThru

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
