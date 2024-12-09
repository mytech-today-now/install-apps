# Install.ps1

<#
.SYNOPSIS
    Main installation framework script that installs programs based on available installation scripts.

.DESCRIPTION
    This script reads all installation scripts from the 'Scripts' subfolder, dot-sources them to extract
    $ProgramName and $ProgramExecutablePath, determines which programs are installed by checking the host system,
    presents a GUI for user selection, and installs the selected programs sequentially while tracking progress.

.NOTES
    Author: @mytech-today-now
    Date:   2024-12-06
#>

# ==============================
# Configuration
# ==============================

# Set the path to the program information folder (scripts directory)
$ProgramInfoFolder = Join-Path -Path $PSScriptRoot -ChildPath "Scripts"

# Set the path to the log file
$LogFilePath = Join-Path -Path $PSScriptRoot -ChildPath "installation.log"

# Set the path to the icon file
$IconPath = Join-Path -Path $PSScriptRoot -ChildPath "icon.ico"

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

Log-Message "Starting Install.ps1" "INFO"

# Check if the Program Information Folder exists
if (-not (Test-Path -Path $ProgramInfoFolder)) {
    Log-Message "Program information folder not found at path: $ProgramInfoFolder" "ERROR"
    exit 1
}

# Get all .ps1 files in the Program Information Folder
$programScripts = Get-ChildItem -Path $ProgramInfoFolder -Filter "*.ps1" -File

if ($programScripts.Count -eq 0) {
    Log-Message "No program information scripts found in folder: $ProgramInfoFolder" "WARN"
    exit 1
}

# Initialize program data array
$programData = @()

foreach ($script in $programScripts) {
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

    # Determine installation status
    $isInstalled = Test-Path -Path $ProgramExecutablePath -or (Is-ProgramInstalledViaRegistry -ProgramName $ProgramName)

    # Add program data to the array
    $programData += [PSCustomObject]@{
        Name = $ProgramName
        Status = if ($isInstalled) { "Installed" } else { "Not Installed" }
        ActionButtonContent = if ($isInstalled) { "Run" } else { "Install" }
        IsInstalled = $isInstalled
        ScriptPath = $script.FullName
        ProgramExecutablePath = $ProgramExecutablePath
    }
}

# ==============================
# GUI Setup
# ==============================

Add-Type -AssemblyName PresentationFramework, PresentationCore

# XAML definition without Click attributes
$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="myTech.Today Installer" Height="500" Width="700" WindowStartupLocation="CenterScreen"
        Background="#245261" Foreground="White" FontFamily="Segoe UI" Icon="$IconPath">
    <Grid Margin="10">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>
        <TextBlock Text="Select Programs to Install:" FontSize="16" Margin="0,0,0,10"/>
        <ListView x:Name="ProgramList" Grid.Row="1" SelectionMode="Extended" Background="#181818" Foreground="#dddddd" FontFamily="Segoe UI" >
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
        # Change status to "Pending Install..."
        $item.Status = "Pending Install..."
        $programList.Items.Refresh()
    }
}

function OnNextClick {
    $nextButton.IsEnabled = $false

    $selectedPrograms = $programData | Where-Object { $_.Status -eq "Pending Install..." }
    $total = $selectedPrograms.Count
    if ($total -eq 0) {
        Log-Message "No programs selected for installation." "INFO"
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

Log-Message "Install.ps1 completed" "INFO"