# MainScript.ps1
<#
.SYNOPSIS
    Main installation framework script that installs programs based on available installation scripts.

.DESCRIPTION
    This script reads all installation scripts from the 'Scripts' subfolder, dot-sources them to extract
    $ProgramName and $ProgramExecutablePath, determines which programs are installed by checking the host system,
    presents a GUI for user selection, and installs the selected programs sequentially while tracking progress.

.NOTES
    Author: Your Name
    Date:   YYYY-MM-DD
#>

# ==============================
# Configuration
# ==============================

# Set the path to the program information folder (scripts directory)
$ProgramInfoFolder = Join-Path -Path $PSScriptRoot -ChildPath "Scripts"

# Set the path to the log file
$LogFilePath = Join-Path -Path $PSScriptRoot -ChildPath "installation.log"

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
            Log-Message "Failed to access registry path: $path. Error: $_" "WARN"
        }
    }
    return $false
}

# ==============================
# Main Script Execution - Script Verification
# ==============================

Log-Message "Starting MainScript.ps1" "INFO"

# Check if the Program Information Folder exists
if (-not (Test-Path -Path $ProgramInfoFolder)) {
    Log-Message "Program information folder not found at path: $ProgramInfoFolder" "ERROR"
    exit 1
}

# Get all .ps1 files in the Program Information Folder
$programScripts = Get-ChildItem -Path $ProgramInfoFolder -Filter "*.ps1" -File

if ($programScripts.Count -eq 0) {
    Log-Message "No program information scripts found in folder: $ProgramInfoFolder" "WARN"
    exit 0
}

$programData = @()

foreach ($script in $programScripts) {
    Log-Message "Processing script: $($script.Name)" "INFO"

    # Initialize variables to prevent carry-over from previous iterations
    $ProgramName = $null
    $ProgramExecutablePath = $null

    # Dot-source the script
    try {
        . $script.FullName
    } catch {
        Log-Message "Failed to dot-source script: $($script.FullName). Error: $_" "ERROR"
        continue
    }

    # Validate that required variables are defined
    if (-not $ProgramName) {
        Log-Message "`$ProgramName is not defined in script: $($script.Name)" "ERROR"
        continue
    }

    if (-not $ProgramExecutablePath) {
        Log-Message "`$ProgramExecutablePath is not defined in script: $($script.Name)" "ERROR"
        continue
    }

    Log-Message "Checking installation status for '$ProgramName'..." "INFO"

    # Determine if the program is installed by checking executable and registry
    $isInstalled = (Test-Path -Path $ProgramExecutablePath) -or (Is-ProgramInstalledViaRegistry -ProgramName $ProgramName)

    if ($isInstalled) {
        Log-Message "$ProgramName is installed." "INFO"
    } else {
        Log-Message "$ProgramName is NOT installed." "WARN"
    }

    $programItem = [PSCustomObject]@{
        Name                  = $ProgramName
        ScriptPath            = $script.FullName
        Status                = if ($isInstalled) { "Installed" } else { "Not Installed" }
        IsInstalled           = $isInstalled
        IsSelected            = -not $isInstalled  # Auto-select if not installed
        ActionButtonContent   = if ($isInstalled) { "Run" } else { "Install" }
        ProgramExecutablePath = $ProgramExecutablePath
    }

    $programData += $programItem

    Log-Message "----------------------------------------" "INFO"
}

Log-Message "Program installation verification completed." "INFO"

# ==============================
# GUI Setup
# ==============================

if (-not (Get-Command -Name Add-Type -ErrorAction SilentlyContinue)) {
    Log-Message "Add-Type not available. Running in a restricted environment?" "ERROR"
    exit 1
}

Add-Type -AssemblyName PresentationFramework, PresentationCore

# Ensure that event handler functions are defined before loading XAML
function OnActionButtonClick {
    param($sender, $e)
    $item = $sender.DataContext

    if ($item.IsInstalled) {
        # Run the program
        if ($item.ProgramExecutablePath -and (Test-Path $item.ProgramExecutablePath)) {
            Log-Message "Running $($item.Name)" "INFO"
            Start-Process -FilePath $item.ProgramExecutablePath
        } else {
            Log-Message "Executable for $($item.Name) not found at $($item.ProgramExecutablePath)." "WARN"
            [System.Windows.MessageBox]::Show("Executable for $($item.Name) not found.", "Error", "OK", "Error")
        }
    } else {
        # Toggle selection for installation
        $item.IsSelected = -not $item.IsSelected
        $item.Status = if ($item.IsSelected) { "Selected" } else { "Not Installed" }
        $programList.Items.Refresh()
    }
}

function OnNextClick {
    $nextButton.IsEnabled = $false

    $selectedPrograms = $programData | Where-Object { $_.IsSelected -and -not $_.IsInstalled }
    $total = $selectedPrograms.Count
    if ($total -eq 0) {
        Log-Message "No programs selected for installation or all are already installed." "INFO"
        # Indicate completion
        $progressBar.Value = 100
        $window.Background = 'Green'
        $window.Title = "Installation Complete"
        return
    }

    $current = 1
    foreach ($program in $selectedPrograms) {
        $progressPercentage = [int](($current - 1) / $total * 100)
        $progressBar.Value = $progressPercentage
        $window.Title = "[$current/$total] Installing: $($program.Name)"

        $program.Status = "Installing"
        $programList.Items.Refresh()

        Log-Message "Installing $($program.Name)" "INFO"
        try {
            # Run the installation script in a separate PowerShell process
            $installProcess = Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File `"$($program.ScriptPath)`"" -Wait -PassThru
            if ($installProcess.ExitCode -ne 0) {
                Log-Message "Installation of $($program.Name) failed with exit code $($installProcess.ExitCode)." "ERROR"
                $program.Status = "Failed"
            } else {
                # After installation, check again if now installed
                $nowInstalled = (Test-Path -Path $program.ProgramExecutablePath) -or (Is-ProgramInstalledViaRegistry -ProgramName $program.Name)
                if ($nowInstalled) {
                    $program.Status = "Installed"
                    $program.IsInstalled = $true
                    $program.ActionButtonContent = "Run"
                    Log-Message "$($program.Name) installed successfully." "INFO"
                } else {
                    Log-Message "$($program.Name) did not appear to be installed after running script." "WARN"
                    $program.Status = "Failed"
                }
            }
        } catch {
            Log-Message "Error installing $($program.Name): $_" "ERROR"
            $program.Status = "Failed"
        }

        $programList.Items.Refresh()
        $current++
    }

    $progressBar.Value = 100
    $window.Background = 'Green'
    $window.Title = "Installation Complete"
    Log-Message "Installation process completed." "INFO"
}

function OnCancelClick {
    Log-Message "Installation cancelled by user." "WARN"
    $window.Close()
}

# XAML definition without Click attributes
$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Installation Framework" Height="500" Width="700" WindowStartupLocation="CenterScreen"
        Background="#2D2D30" Foreground="White" FontFamily="Segoe UI">
    <Grid Margin="10">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>
        <TextBlock Text="Select Programs to Install:" FontSize="16" Margin="0,0,0,10"/>
        <ListView x:Name="ProgramList" Grid.Row="1" SelectionMode="Extended">
            <ListView.View>
                <GridView>
                    <GridViewColumn Header="Program" DisplayMemberBinding="{Binding Name}" Width="300"/>
                    <GridViewColumn Header="Status" DisplayMemberBinding="{Binding Status}" Width="100"/>
                    <GridViewColumn Header="Action" Width="100">
                        <GridViewColumn.CellTemplate>
                            <DataTemplate>
                                <Button Content="{Binding ActionButtonContent}" Width="80"/>
                            </DataTemplate>
                        </GridViewColumn.CellTemplate>
                    </GridViewColumn>
                </GridView>
            </ListView.View>
        </ListView>
        <ProgressBar x:Name="ProgressBar" Grid.Row="2" Height="20" Margin="0,10,0,0" Minimum="0" Maximum="100"/>
        <StackPanel Grid.Row="3" Orientation="Horizontal" HorizontalAlignment="Right" Margin="0,10,0,0">
            <Button x:Name="CancelButton" Content="Cancel" Width="80"/>
            <Button x:Name="NextButton" Content="Next" Width="80" Margin="10,0,0,0"/>
        </StackPanel>
    </Grid>
</Window>
"@

$reader = [System.Xml.XmlReader]::Create([System.IO.StringReader]$xaml)
try {
    $window = [Windows.Markup.XamlReader]::Load($reader)
} catch {
    Log-Message "Error loading XAML: $_" "ERROR"
    exit 1
}

# Find controls
$programList = $window.FindName("ProgramList")
$progressBar = $window.FindName("ProgressBar")
$nextButton = $window.FindName("NextButton")
$cancelButton = $window.FindName("CancelButton")

$programList.ItemsSource = $programData

# ==============================
# Event Handlers
# ==============================

# Add event handlers to the controls
$nextButton.Add_Click({ OnNextClick })
$cancelButton.Add_Click({ OnCancelClick })

# Add event handler for the action buttons in the ListView
$programList.AddHandler([System.Windows.Controls.Primitives.ButtonBase]::ClickEvent,
    [System.Windows.RoutedEventHandler]{
        param($sender, $e)
        if ($e.OriginalSource -is [System.Windows.Controls.Button]) {
            OnActionButtonClick $e.OriginalSource $e
        }
    })

# Show the window
Log-Message "Displaying the GUI" "INFO"
$null = $window.ShowDialog()

Log-Message "MainScript.ps1 completed" "INFO"