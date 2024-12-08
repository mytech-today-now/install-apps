# RenameIt.ps1

$ProgramName = "Rename-It!"
$ProgramExecutablePath = "C:\Program Files\Rename-It!\renameit.exe"
$DownloadsPageURL = "https://sourceforge.net/projects/renameit/files/latest/download"
$TempDir = "$env:TEMP\RenameItInstaller"
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

function IsInstalled {
    Test-Path $ProgramExecutablePath
}

function Install-Program {
    Write-Log "Installing $ProgramName"
    try {
        # SourceForge direct link usually redirects to a binary. We might just download directly.
        $installerPath = Join-Path $TempDir "renameit_installer.exe"
        Invoke-WebRequest -Uri $DownloadsPageURL -OutFile $installerPath

        if (-not (Test-Path $installerPath)) { throw "Download failed." }

        # Likely Inno Setup
        Write-Log "Silent installation"
        $installProcess = Start-Process -FilePath $installerPath -ArgumentList "/verysilent","/norestart" -Wait -PassThru
        if ($installProcess.ExitCode -ne 0) { throw "Installation failed." }

        Write-Log "$ProgramName installed successfully."
    } catch {
        Write-Log "Error: $_"
        throw $_
    } finally {
        Remove-Item $TempDir -Recurse -Force
    }
}
