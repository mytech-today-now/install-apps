# WiseDuplicateFinder.ps1

$ProgramName = "Wise Duplicate Finder"
$ProgramExecutablePath = "C:\Program Files (x86)\Wise\Wise Duplicate Finder\WiseDuplicateFinder.exe"
$DownloadsPageURL = "https://www.wisecleaner.com/wise-duplicate-finder.html"
$TempDir = "$env:TEMP\WiseDuplicateFinderInstaller"
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

function IsInstalled {
    Test-Path $ProgramExecutablePath
}

function Install-Program {
    Write-Log "Installing $ProgramName"
    try {
        $html = Invoke-WebRequest -Uri $DownloadsPageURL -UseBasicParsing
        # Possibly WDFSetup.exe or Wise-Duplicate-Finder-Setup.exe
        $installerLink = ($html.Links | Where-Object { $_.href -match "WDFSetup.*\.exe$" -or $_.href -match "Wise-Duplicate-Finder-Setup.*\.exe$" }).href | Select-Object -First 1
        if (-not $installerLink) { throw "No installer link found." }

        if ($installerLink -notmatch "^https?://") {
            $installerURL = [System.Uri]::new([System.Uri]$DownloadsPageURL, $installerLink).AbsoluteUri
        } else {
            $installerURL = $installerLink
        }

        $installerPath = Join-Path $TempDir "wise_duplicate_finder_installer.exe"
        Invoke-WebRequest -Uri $installerURL -OutFile $installerPath

        # Inno Setup style
        Write-Log "Silent installation"
        $installProcess = Start-Process -FilePath $installerPath -ArgumentList "/verysilent","/norestart" -Wait -PassThru
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
