<#
  Quick script to setup a windows server for packer builds
#>

$ErrorActionPreference = "Stop"

Write-Host "$(Get-Date -format T) - Start of script"

### Variables ###

$downloadURL = "https://go.microsoft.com/fwlink/?linkid=2196127" # test link
$downloadPath = $env:TEMP
$installPath = "C:\Program Files (x86)\Windows Kits\10"
$oscdimgCheck = "$installPath\Assessment and Deployment Kit\Deployment Tools\x86\Oscdimg\oscdimg.exe"
$installerPath = "$downloadPath\adksetup.exe"
$packages = @( # List of packages to ensure are installed with chocolatey
    "powershell-core",
    "git",
    "vmware-powercli-psmodule",
    #"az.powershell",
    #"azure-cli",
    "terraform",
    "packer"
)

### Functions ###

# Function to Check Elevated Privileges
function Check-Admin {
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { 
        Write-Error "$(Get-Date -format T) - This script must be run as an administrator." 
        exit 1
    }
}

# Function to Add Oscdimg Directory to PATH
function Add-OscdimgToPath {
    $oscdimgPath = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\x86\Oscdimg"
    $oldPath = [System.Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::Machine)

    if ($oldPath.Split(';') -contains $oscdimgPath) {
        Write-Host "$(Get-Date -format T) - Oscdimg path is already in the PATH variable"
    } else {
        $newPath = $oldPath + ";" + $oscdimgPath
        [System.Environment]::SetEnvironmentVariable('Path', $newPath, [System.EnvironmentVariableTarget]::Machine)
        Write-Host "$(Get-Date -format T) - Added oscdimg to PATH"
    }
}

# Function to Download ADK Installer
function Download-ADK {
    if (Test-Path $installerPath) {
        Write-Host "$(Get-Date -format T) - ADK installer already exists: $installerPath"
    } else {
        try {
            Invoke-WebRequest -Uri $downloadURL -OutFile $installerPath -ErrorAction Stop
            Write-Host "$(Get-Date -format T) - Downloaded ADK installer to: $installerPath"
        } catch {
            Write-Error "$(Get-Date -format T) - Failed to download ADK installer: $_"
            exit 1
        }
    }
}

# Function to Verify and Install Oscdimg
function Verify-And-Install-Oscdimg {
    if (Test-Path $oscdimgCheck) {
        Write-Host "$(Get-Date -format T) - oscdimg is installed"
        & $oscdimgCheck
    } else {
        Write-Host "$(Get-Date -format T) - ADK does not appear to be installed, installing."
        try {
            $command = "$installerPath /quiet /installpath `"$installPath`" /features OptionId.DeploymentTools"
            cmd.exe /c $command
            Write-Host "$(Get-Date -format T) - ADK setup finished."
            & $oscdimgCheck
        } catch {
            Write-Error "$(Get-Date -format T) - Failed to start the ADK setup: $_"
            exit 1
        }
    }
}

# Function to Clean Up Installer File
function Cleanup-Installer {
    if (Test-Path $installerPath) {
        Remove-Item -Path $installerPath -Force
        Write-Host "$(Get-Date -format T) - Deleted the downloaded installer file: $installerPath"
    } else {
        Write-Host "$(Get-Date -format T) - Installer file was not found: $installerPath"
    }
}

# Function to check if Chocolatey is installed
function Is-ChocolateyInstalled {
    try {
        choco --version | Out-Null
        return $true
    } catch {
        return $false
    }
}

# Function to check if a package is installed
function Is-PackageInstalled {
    param (
        [string]$packageName
    )
    $installed = choco list | Select-String -Pattern $packageName
    return $installed -ne $null
}

# Function to install a package if not installed
function Install-Package {
    param (
        [string]$packageName
    )
    if (-not (Is-PackageInstalled -packageName $packageName)) {
        Write-Host "$(Get-Date -format T) - Installing $packageName..."
        choco install $packageName -y
    } else {
        Write-Host "$(Get-Date -format T) - $packageName is already installed, checking for updates."
        choco upgrade $packageName -y
    }
}

### Main Script Execution ###

# Check if NuGet is installed
Write-Output "$(Get-Date -format T) - Installing NuGet"
Get-PackageProvider -Name NuGet -ForceBootstrap -ErrorAction SilentlyContinue

# Trust PSGallery
Set-PSRepository -InstallationPolicy Trusted -Name PSGallery

# Check if oscdimg is installed
Write-Output "$(Get-Date -format T) - Installing oscdimg"
Check-Admin
Add-OscdimgToPath
Download-ADK
Verify-And-Install-Oscdimg
Cleanup-Installer

# Install Chocolatey if it is not already installed
if (-not (Is-ChocolateyInstalled)) {
    Write-Host "$(Get-Date -format T) - Chocolatey is not installed. Installing now..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    Write-Host "$(Get-Date -format T) - Chocolatey installed successfully."
} else {
    Write-Host "$(Get-Date -format T) - Chocolatey is already installed."
}

# Iterate over the package list and ensure each is installed
foreach ($package in $packages) {
    Write-Host "$(Get-Date -format T) - Installing: $package"
    Install-Package -packageName $package
}

Write-Host "$(Get-Date -format T) - End of script"
