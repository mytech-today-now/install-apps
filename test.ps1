# ==============================
# VerifyProgramInstallation.ps1
# ==============================

<#
.SYNOPSIS
    Verifies the installation status of programs based on their information scripts.

.DESCRIPTION
    This script reads all PowerShell scripts in a designated folder, each containing
    program information variables ($ProgramName and $ProgramExecutablePath), and
    checks whether each program is installed on the local host by verifying the
    existence of its executable and optionally checking the Windows Registry.

.NOTES
    Author: [Your Name]
    Date: [Date]
#>

# ==============================
# Configuration
# ==============================

# Path to the folder containing program information scripts
$ProgramInfoFolder = "G:\Insidious_Meme\github\install-apps\Scripts"

# Optional: Define log file path
$LogFilePath = ".\installation.log"

# ==============================
# Functions
# ==============================

function Log-Message {
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
            # Handle any access or retrieval errors
            Log-Message "Failed to access registry path: $path. Error: $_" "WARN"
        }
    }
    return $false
}

# ==============================
# Main Script Execution
# ==============================

# Check if the Program Information Folder exists
if (-Not (Test-Path -Path $ProgramInfoFolder)) {
    Log-Message "Program information folder not found at path: $ProgramInfoFolder" "ERROR"
    exit 1
}

# Get all .ps1 files in the Program Information Folder
$programScripts = Get-ChildItem -Path $ProgramInfoFolder -Filter "*.ps1" -File

if ($programScripts.Count -eq 0) {
    Log-Message "No program information scripts found in folder: $ProgramInfoFolder" "WARN"
    exit 0
}

# Iterate through each program information script
foreach ($script in $programScripts) {
    Log-Message "Processing script: $($script.Name)" "INFO"

    # Initialize variables to prevent carry-over from previous iterations
    $ProgramName = $null
    $ProgramExecutablePath = $null

    # Dot-source the script within a script block to isolate its scope
    try {
        . $script.FullName
    } catch {
        Log-Message "Failed to dot-source script: $($script.FullName). Error: $_" "ERROR"
        continue
    }

    # Validate that required variables are defined
    if (-Not $ProgramName) {
        Log-Message "`$ProgramName is not defined in script: $($script.Name)" "ERROR"
        continue
    }

    if (-Not $ProgramExecutablePath) {
        Log-Message "`$ProgramExecutablePath is not defined in script: $($script.Name)" "ERROR"
        continue
    }

    Log-Message "Checking installation status for '$ProgramName'..." "INFO"

    # Check if the executable path exists
    if (Test-Path -Path $ProgramExecutablePath) {
        Log-Message "$ProgramName is installed at $ProgramExecutablePath." "INFO"
    } else {
        Log-Message "$ProgramName is NOT installed at the expected path: $ProgramExecutablePath." "WARN"
    }

    # Optional: Additional verification using the registry
    if (Is-ProgramInstalledViaRegistry -ProgramName $ProgramName) {
        Log-Message "$ProgramName is confirmed installed via registry." "INFO"
    } else {
        Log-Message "$ProgramName is NOT found in the registry." "WARN"
    }

    Log-Message "----------------------------------------" "INFO"
}

Log-Message "Program installation verification completed." "INFO"
