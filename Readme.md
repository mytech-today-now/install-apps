# Installation Framework

MainScript.ps1 is a PowerShell script that serves as a main installation framework. It reads all installation scripts from the `Scripts` subfolder, determines which programs are installed on the host system, presents a GUI for user selection, and installs the selected programs sequentially while tracking progress.

## Features

- **Automatic Detection**: Identifies which programs are already installed.
- **User-Friendly GUI**: Provides an intuitive interface for selecting programs to install.
- **Extensibility**: Easily add new program installation scripts to the `Scripts` folder.
- **Logging**: Logs installation progress and errors to `installation.log`.

## Prerequisites

- **Operating System**: Windows 7 or higher.
- **PowerShell Version**: Windows PowerShell 5.1.
- **Execution Policy**: Set to allow script execution (`RemoteSigned` or `Bypass`).
- **.NET Framework**: .NET Framework 4.5 or higher (for WPF support).

## Installation

1. **Clone the Repository**

   ```shell
   git clone https://github.com/yourusername/installation-framework.git
   ```

2. **Navigate to the Repository Directory**

   ```shell
   cd installation-framework
   ```

3. **Verify the Scripts Folder**

   Ensure that the `Scripts` subfolder contains the installation scripts for the programs you wish to manage.

## Usage

1. **Ensure Execution Policy Allows Scripts**

   Open PowerShell as an administrator and run:

   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

2. **Run MainScript.ps1**

   ```powershell
   .\MainScript.ps1
   ```

3. **Use the GUI**

   - The GUI displays a list of programs with their installation status.
   - Select the programs you wish to install by clicking the "Install" button next to them.
   - Click the **Next** button to begin the installation process.
   - Monitor the progress through the progress bar and status messages.

## Adding New Installation Scripts

To add a new program to the installation framework:

1. **Create a New Script**

   In the `Scripts` folder, create a new PowerShell script (e.g., `myprogram.ps1`).

2. **Define Required Variables and Functions**

   ```powershell
   # Program Name
   $ProgramName = "My Program"

   # Path to the program's executable after installation
   $ProgramExecutablePath = "C:\Program Files\MyProgram\myprogram.exe"

   # Function to check if the program is installed
   function IsInstalled {
       return Test-Path $ProgramExecutablePath
   }

   # Function to install the program
   function Install-Program {
       # Your installation logic here
       # e.g., download installer, execute installer with silent options, etc.
   }
   ```

3. **Ensure Logging is Used**

   Within your `Install-Program` function, use the `Write-Log` function to record progress and errors.

   ```powershell
   function Write-Log {
       param (
           [string]$Message
       )
       $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
       $logEntry = "$timestamp [INFO] $Message"
       Write-Output $logEntry
       Add-Content -Path $LogFilePath -Value $logEntry
   }
   ```

## Script Structure

- **MainScript.ps1**: The main framework script that loads program scripts, detects installed programs, manages the GUI, and handles the installation process.
- **Scripts Folder**: Contains individual program installation scripts (`.ps1` files).
- **installation.log**: Log file where all messages are recorded.
- **icon.ico** (Optional): An icon file used by the GUI window.

## Customizing the GUI Icon

If you wish to display a custom icon in the GUI:

1. Place your `icon.ico` file in the root directory of the repository.
2. Ensure the following line in `MainScript.ps1` correctly references the icon path:

   ```powershell
   $IconPath = Join-Path -Path $PSScriptRoot -ChildPath "icon.ico"
   ```

3. In the XAML section of `MainScript.ps1`, make sure the `Icon` attribute uses the `$IconPath` variable:

   ```xml
   <Window ... Icon="$IconPath">
       <!-- GUI elements -->
   </Window>
   ```

## Logging

All operations are logged to `installation.log` in the repository's root directory. The log includes timestamps and message levels (INFO, WARN, ERROR).

## Troubleshooting

- **Script Execution is Blocked**: Ensure your execution policy permits running scripts. Run PowerShell as administrator and set the execution policy:

  ```powershell
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
  ```

- **GUI Does Not Appear**: Confirm that your PowerShell environment supports Windows Presentation Foundation (WPF). PowerShell 5.1 is required.

- **Errors Loading XAML**: If you receive errors about loading XAML or missing resources, check that the paths to resources like icons are correct and that they exist.

- **Installation Fails**: Review `installation.log` for detailed error messages.

## Contributing

Contributions are welcome! To contribute:

1. **Fork the Repository**

2. **Create a Feature Branch**

   ```shell
   git checkout -b feature/YourFeature
   ```

3. **Commit Your Changes**

   ```shell
   git commit -am 'Add new feature'
   ```

4. **Push to the Branch**

   ```shell
   git push origin feature/YourFeature
   ```

5. **Open a Pull Request**

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contact

- **Author**: [@mytech-today-now](https://github.com/mytech-today-now)
- **Email**: mytechtoday@protonmail.com

## Acknowledgments

- Inspired by the need for an automated, user-friendly installation process for commonly used applications.
- Thanks to all contributors who have helped improve this project.

---

*Please ensure all scripts are tested in a safe environment before deploying in production.*