# AviraFreeAntivirus.ps1

# Import common functions
. "$PSScriptRoot\..\Common.ps1"

$ProgramName = "Avira Free Antivirus"
$ProgramExecutablePath = "C:\Program Files\Avira\Endpoint Protection SDK\endpointprotection.exe"
$DownloadsPageURL = "https://www.avira.com/en/free-antivirus-windows"
$TempDir = "$env:TEMP\AviraInstaller"
$LogFilePath = Join-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "..\") -ChildPath "installation.log"

New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

function IsInstalled {
    return Test-Path $ProgramExecutablePath
}

function Install-Program {
    Write-Log "Starting installation of $ProgramName" "INFO"
    try {
        Write-Log "Retrieving the latest download link from $DownloadsPageURL" "INFO"
        $htmlContent = Invoke-WebRequest -Uri $DownloadsPageURL -UseBasicParsing

        $installerLink = ($htmlContent.Links | Where-Object { $_.href -match "Avira.*\.exe$" }).href | Select-Object -First 1

        if (-not $installerLink) {
            Write-Log "Error: Unable to find the Avira installer link." "ERROR"
            throw "Installer link not found."
        }

        if ($installerLink -notmatch "^https?://") {
            $uri = [System.Uri]$DownloadsPageURL
            $installerURL = [System.Uri]::new($uri, $installerLink).AbsoluteUri
        } else {
            $installerURL = $installerLink
        }

        Write-Log "Latest installer URL: $installerURL" "INFO"
        $installerPath = Join-Path $TempDir "avira_installer.exe"
        Write-Log "Downloading installer to $installerPath" "INFO"
        Invoke-WebRequest -Uri $installerURL -OutFile $installerPath

        if (-not (Test-Path $installerPath)) {
            Write-Log "Error: Installer download failed." "ERROR"
            throw "Installer download failed."
        }

        Write-Log "Starting silent installation" "INFO"
        $installProcess = Start-Process -FilePath $installerPath -ArgumentList "/silent" -Wait -PassThru

        if ($installProcess.ExitCode -ne 0) {
            Write-Log "Error: Installation failed with exit code $($installProcess.ExitCode). Trying /S..." "ERROR"
            $installProcess = Start-Process -FilePath $installerPath -ArgumentList "/S" -Wait -PassThru
            if ($installProcess.ExitCode -ne 0) {
                Write-Log "Error: Still failed with exit code $($installProcess.ExitCode)." "ERROR"
                throw "Installation failed."
            }
        }

        Write-Log "$ProgramName installation completed successfully." "INFO"
    } catch {
        Write-Log "Error during installation: $_" "ERROR"
        throw $_
    } finally {
        Write-Log "Cleaning up temporary files" "INFO"
        Remove-Item $TempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

if (-not (IsInstalled)) {
    Install-Program
} else {
    Write-Log "$ProgramName is already installed." "INFO"
}