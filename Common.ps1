# Common.ps1

function Write-Log {
    param (
        [string]$Message,
        [ValidateSet("INFO", "WARN", "ERROR")] [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp [$Level] $Message"
    Write-Output $logEntry
    if ($LogFilePath) {
        Add-Content -Path $LogFilePath -Value $logEntry
    }
}

function Is-ProgramInstalledViaRegistry {
    param (
        [string]$ProgramName
    )

    $registryPaths = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )

    foreach ($path in $registryPaths) {
        try {
            $keys = Get-ItemProperty -Path $path -ErrorAction SilentlyContinue | Where-Object {
                $_.DisplayName -like "*$ProgramName*"
            }
            if ($keys) {
                return $true
            }
        } catch {
            Write-Log "Failed to access registry path: $path. Error: $_" "WARN"
        }
    }
    return $false
}

function Install-Program {
    param (
        [string]$ProgramName,
        [string]$ProgramExecutablePath,
        [string]$DownloadsPageURL,
        [string]$TempDir,
        [string]$InstallerPattern,
        [string]$InstallerArguments = "/S"
    )

    Write-Log "Starting installation of $ProgramName" "INFO"
    try {
        Write-Log "Retrieving the latest download link from $DownloadsPageURL" "INFO"
        
        $htmlContent = Invoke-WebRequest -Uri $DownloadsPageURL -UseBasicParsing
        $installerLink = ($htmlContent.Links | Where-Object { $_.href -match $InstallerPattern }).href | Select-Object -First 1

        if (-not $installerLink) {
            Write-Log "Error: Unable to find the $ProgramName installer link." "ERROR"
            throw "Installer link not found."
        }

        if ($installerLink -notmatch "^https?://") {
            $uri = [System.Uri]$DownloadsPageURL
            $installerURL = [System.Uri]::new($uri, $installerLink).AbsoluteUri
        } else {
            $installerURL = $installerLink
        }

        Write-Log "Installer URL: $installerURL" "INFO"
        $installerPath = Join-Path $TempDir "$($ProgramName)_installer.exe"
        Write-Log "Downloading installer to $installerPath" "INFO"
        Invoke-WebRequest -Uri $installerURL -OutFile $installerPath

        if (-not (Test-Path $installerPath)) {
            Write-Log "Error: download failed." "ERROR"
            throw "Installer download failed."
        }

        Write-Log "Starting silent installation" "INFO"
        $installProcess = Start-Process -FilePath $installerPath -ArgumentList $InstallerArguments -Wait -PassThru

        if ($installProcess.ExitCode -ne 0) {
            Write-Log "Installation failed with exit code $($installProcess.ExitCode)." "ERROR"
            throw "Installation failed."
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