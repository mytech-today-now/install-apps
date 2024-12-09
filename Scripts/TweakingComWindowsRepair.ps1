# TweakingComWindowsRepair.ps1

$ProgramName = "Tweaking.com Windows Repair"
$ProgramExecutablePath = "C:\Program Files (x86)\Tweaking.com\Simple System Tweaker\Simple_System_Tweaker.exe"
$DownloadsPageURL = "https://www.tweaking.com/"
$TempDir = "$env:TEMP\TweakingComInstaller"
$LogFilePath = Join-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "..\") -ChildPath "installation.log"

New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

function Write-Log {
    param (
        [string]$Message,
        [ValidateSet("INFO", "WARN", "ERROR")] [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp [$Level] $Message"
    Write-Output $logEntry
    Add-Content -Path $LogFilePath -Value $logEntry
}

function IsInstalled {
    return Test-Path $ProgramExecutablePath
}

function Install-Program {
    Write-Log "Installing $ProgramName" "INFO"
    try {
        $html = Invoke-WebRequest -Uri $DownloadsPageURL -UseBasicParsing
        $installerLink = ($html.Links | Where-Object { $_.href -match "windows_repair_aio_setup.*\.exe$" }).href | Select-Object -First 1
        if (-not $installerLink) {
            Write-Log "No installer link found." "ERROR"
            throw "No installer link found."
        }

        if ($installerLink -notmatch "^https?://") {
            $installerURL = [System.Uri]::new([System.Uri]$DownloadsPageURL, $installerLink).AbsoluteUri
        } else {
            $installerURL = $installerLink
        }

        $installerPath = Join-Path $TempDir "tweakingcom_installer.exe"
        Invoke-WebRequest -Uri $installerURL -OutFile $installerPath

        Write-Log "Silent installation" "INFO"
        $installProcess = Start-Process -FilePath $installerPath -ArgumentList "/verysilent","/norestart" -Wait -PassThru
        if ($installProcess.ExitCode -ne 0) {
            Write-Log "Failed." "ERROR"
            throw "Failed."
        }

        Write-Log "$ProgramName installed successfully." "INFO"
    } catch {
        Write-Log "Error: $_" "ERROR"
        throw $_
    } finally {
        Remove-Item $TempDir -Recurse -Force
    }
}

if (-not (IsInstalled)) {
    Install-Program
} else {
    Write-Log "$ProgramName is already installed." "INFO"
}