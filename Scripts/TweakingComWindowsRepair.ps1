# TweakingComWindowsRepair.ps1

$ProgramName = "Tweaking.com Windows Repair"
$ProgramExecutablePath = "C:\Program Files (x86)\Tweaking.com\Simple System Tweaker\Simple_System_Tweaker.exe"
$DownloadsPageURL = "https://www.tweaking.com/"
$TempDir = "$env:TEMP\TweakingComInstaller"
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

function IsInstalled {
    Test-Path $ProgramExecutablePath
}

function Install-Program {
    Write-Log "Installing $ProgramName"
    try {
        $html = Invoke-WebRequest -Uri $DownloadsPageURL -UseBasicParsing
        # Something like tweaking.com_windows_repair_aio_setup.exe
        $installerLink = ($html.Links | Where-Object { $_.href -match "windows_repair_aio_setup.*\.exe$" }).href | Select-Object -First 1
        if (-not $installerLink) { throw "No installer link found." }

        if ($installerLink -notmatch "^https?://") {
            $installerURL = [System.Uri]::new([System.Uri]$DownloadsPageURL, $installerLink).AbsoluteUri
        } else {
            $installerURL = $installerLink
        }

        $installerPath = Join-Path $TempDir "tweakingcom_installer.exe"
        Invoke-WebRequest -Uri $installerURL -OutFile $installerPath

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
