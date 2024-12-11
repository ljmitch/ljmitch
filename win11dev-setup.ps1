# Quick and dirty script to configure a Windows 11 IDE environment on a clean install

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Unwanted apps installed by default
$appsToRemove = @(
    "Clipchamp.Clipchamp",
    "Microsoft.BingNews",
    "Microsoft.BingSearch",
    "Microsoft.BingWeather",
    "Microsoft.Copilot",
    "Microsoft.GamingApp",
    "Microsoft.GetHelp",
    "Microsoft.MicrosoftOfficeHub",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.MicrosoftStickyNotes",
    "Microsoft.OutlookForWindows",
    "Microsoft.PowerAutomateDesktop",
    "Microsoft.ScreenSketch",
    "Microsoft.Teams",
    "Microsoft.Todos",
    "Microsoft.WindowsCamera",
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.WindowsSoundRecorder",
    "Microsoft.Windows.Photos",
    "Microsoft.WindowsAlarms",
    "Microsoft.XboxApp",
    "Microsoft.Xbox.TCUI",
    "Microsoft.XboxGamingOverlay",
    "Microsoft.XboxIdentityProvider",
    "Microsoft.XboxSpeechToTextOverlay",
    "Microsoft.YourPhone",
    "Microsoft.ZuneMusic",
    "MicrosoftCorporationII.QuickAssist",
    "MicrosoftWindows.CrossDevice",
    "MSTeams"
)

# Loop through each app and remove it
foreach ($app in $appsToRemove) {
    Get-AppxPackage -Name $app | Remove-AppxPackage
}

# Remove OneDrive separately because it's a special snowflake
winget uninstall Microsoft.OneDrive

# remove the Microsoft Store app from the taskbar
$appname = "Microsoft Store"
((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | Where-Object {$_.Name -eq $appname}).Verbs() | Where-Object {$_.Name.replace('&', '') -match 'Unpin from taskbar'} | ForEach-Object {$_.DoIt()}

# Set desktop background to solid RGB colour (via reg tweaks section)
$red = 76
$green = 74
$blue = 72

# Reg tweaks to make me happy
$settings =
[pscustomobject]@{
    Path        = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer"
    Name        = "EnableAutoTray"
    Value       = 0
    Description = "Disable Auto Tray"
},
[pscustomobject]@{
    Path        = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"
    Name        = "SearchBoxTaskbarMode"
    Value       = 0
    Type        = "DWord"
    Description = "Hide Search Box"
},
[pscustomobject]@{
    Path        = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    Name        = "ShowTaskViewButton"
    Value       = 0
    Description = "Hide Task View Button"
},
[pscustomobject]@{
    Path        = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    Name        = "ShowStartMenuApps"
    Value       = 0
    Description = "Hide Start Menu Apps"
},
[pscustomobject]@{
    Path  = "Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
    Value = 0
    Name = "{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
    Description = "This PC"
},
[PSCustomObject]@{
    Path  = "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    Value = 0
    Name  = "TaskbarAl"
},
[PSCustomObject]@{
    Path  = "SOFTWARE\Policies\Microsoft\Dsh"
    Value = 0
    Name  = "AllowNewsAndInterests"
},
[PSCustomObject]@{
    Path  = "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    Value = 0
    Name  = "ShowCopilotButton"
},
[pscustomobject]@{
    Path  = "Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
    Value = 0
    Name = "{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}"
    Description = "Control Panel"
},
[pscustomobject]@{
    Path  = "Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
    Value = 0
    Name = "{59031a47-3f72-44a7-89c5-5595fe6b30ee}"
    Description = "User's Files"
},
[pscustomobject]@{
    Path  = "Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
    Value = 0
    Name = "{645FF040-5081-101B-9F08-00AA002F954E}"
    Description = "Recycle Bin"
},
[pscustomobject]@{
    Path  = "Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
    Value = 0
    Name = "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}"
    Description = "Network"
},
[pscustomobject]@{
    Path        = "HKCU:\Control Panel\Colors"
    Name        = "Background"
    Value       = "$red $green $blue"
    Description = "Set Solid Color Background"
},
[pscustomobject]@{
    Path        = "HKCU:\Control Panel\Desktop"
    Name        = "Wallpaper"
    Value       = ""
    Description = "Use Solid Color Background"
},
[pscustomobject]@{
    Path        = "HKCU:\Control Panel\Desktop"
    Name        = "WallPaperStyle"
    Value       = "0"
    Description = "Set Wallpaper Style"
},
[pscustomobject]@{
    Path        = "HKCU:\Control Panel\Desktop"
    Name        = "TileWallpaper"
    Value       = "0"
    Description = "Set Tile Wallpaper"
},
[pscustomobject]@{
    Path        = "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server"
    Name        = "fDenyTSConnections"
    Value       = 0
},
[pscustomobject]@{
    Path        = "HKLM\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp"
    Name        = "UserAuthentication"
    Value       = 0
} | Group-Object Path

foreach($setting in $desktop_icons){
    $registry = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey($setting.Name, $true)
    if ($null -eq $registry) {
        $registry = [Microsoft.Win32.Registry]::CurrentUser.CreateSubKey($setting.Name, $true)
    }
    $setting.Group | %{
        $registry.SetValue($_.name, $_.value)
    }
    $registry.Dispose()
}

# Add system environmental variable - show nonpresent devices - used with device manager
[Environment]::SetEnvironmentVariable("devmgr_show_nonpresent_devices", "1", "Machine")

# List of services to disable
$servicesToDisable = @(
    "SharedAccess",
    "lltdsvc",
    "ScDeviceEnum",
    "wisvc",
    "AxInstSV",
    "bthserv",
    "CDPUserSvc",
    "PimIndexMaintenanceSvc",
    "dmwappushservice",
    "MapsBroker",
    "lfsvc",
    "wlidsvc",
    "Spooler",
    "PrintNotify",
    "PcaSvc",
    "QWAVE",
    "RmSvc",
    "SensorDataService",
    "SensrSvc",
    "SensorService",
    "ShellHWDetection",
    "SSDPSRV",
    "WiaRpc",
    "upnphost",
    "UserDataSvc",
    "UnistoreSvc",
    "WalletService",
    "Audiosrv",
    "AudioEndpointBuilder",
    "FrameServer",
    "stisvc",
    "WpnService",
    "WpnUserService",
    "Themes"
)

# Loop through each service and disable it
foreach ($service in $servicesToDisable) {
    Get-Service -Name $service | Set-Service -StartupType Disabled | Out-Null
}

# Check if PSWindowsUpdate module is installed for Windows updates via PowerShell
$psWindowsUpdateModule = Get-Module -ListAvailable -Name PSWindowsUpdate
if (-not $psWindowsUpdateModule) {
    Install-Module -Name PSWindowsUpdate -Force -Confirm:$false
} else {
    Write-Output "$(Get-Date -format T) - PSWindowsUpdate module is already installed"
}

# Install Windows Updates
Import-Module -Name PSWindowsUpdate
Install-WindowsUpdate -AcceptAll -IgnoreReboot -AutoReboot:$false

# Install apps I want
Get-PackageProvider -Name NuGet -ForceBootstrap
#Install-PackageProvider -Name NuGet -Force
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
Install-Module -Name Az -Repository PSGallery # Az PowerShell module

# List of apps to install with winget
$appsToInstall = @(
    "Microsoft.WindowsTerminal",
    "Microsoft.PowerShell",
    "7zip.7zip",
    "PuTTY.PuTTY",
    "Notepad++.Notepad++",
    "Git.Git",
    "GitHub.cli",
    "Hashicorp.Terraform",
    "Hashicorp.Packer",
    "Microsoft.AzureCLI",
    "Microsoft.Azure.AztfExport",
    "Microsoft.Bicep",
    "Microsoft.VisualStudioCode"
)

# Loop through each app and install it using winget
foreach ($app in $appsToInstall) {
    winget install $app --silent --accept-package-agreements --accept-source-agreements
}

# Configure Git
$gitUsername = "ljmitch"
$gitEmail = "ljmitch@gmail.com"

# Path to the Git executable - because its only just been installed (probably!)
$gitPath = "C:\Program Files\Git\cmd\git.exe"

# Git config commands
Start-Process -FilePath $gitPath -ArgumentList "config --global user.name '$gitUsername'" -NoNewWindow -Wait
Start-Process -FilePath $gitPath -ArgumentList "config --global user.email '$gitEmail'" -NoNewWindow -Wait
Start-Process -FilePath $gitPath -ArgumentList "config --global push.default current" -NoNewWindow -Wait
Start-Process -FilePath $gitPath -ArgumentList "config --global push.autoSetupRemote true" -NoNewWindow -Wait
Start-Process -FilePath $gitPath -ArgumentList "config --global pull.rebase true" -NoNewWindow -Wait
Start-Process -FilePath $gitPath -ArgumentList "config --global core.editor code -w" -NoNewWindow -Wait
Start-Process -FilePath $gitPath -ArgumentList "config --global init.defaultBranch main" -NoNewWindow -Wait

# List of VS Code extensions to install
$extensions = @(
    "dbaeumer.vscode-eslint",
    "esbenp.prettier-vscode",
    "github.vscode-pull-request-github",
    "streetsidesoftware.code-spell-checker",
    "ms-vscode.azure-account",
    "azure-automation.vscode-azureautomation",
    "ms-azuretools.vscode-azurefunctions",
    "ms-vscode.azurecli",
    "ms-azuretools.vscode-azureresourcegroups",
    "ms-azuretools.vscode-azureterraform",
    "ms-azuretools.vscode-bicep",
    "fabiospampinato.vscode-diff",
    "hashicorp.hcl",
    "hashicorp.terraform",
    "oderwat.indent-rainbow",
    "visualstudioexptteam.vscodeintellicode",
    "yzhang.markdown-all-in-one",
    "bierner.markdown-preview-github-styles",
    "ibm.output-colorizer",
    "ms-vscode.powershell",
    "mechatroner.rainbow-csv",
    "vscode-icons-team.vscode-icons",
    "redhat.vscode-yaml",
    "eamodio.gitlens",
    "ibm.output-colorizer",
    "vsls-contrib.gistfs",
    "mhutchie.git-graph",
    "dotjoshjohnson.xml",
    "continue.continue",
    "supermaven.supermaven"
)

# Path to the VS Code executable - because its only just been installed (probably!)
$codePath = "C:\Users\$env:USERNAME\AppData\Local\Programs\Microsoft VS Code\bin\code.cmd"

# Loop through each extension and install it using code
foreach ($extension in $extensions) {
    Start-Process -FilePath $codePath -ArgumentList "--install-extension $extension --force" -NoNewWindow -Wait
}

# uninstall ALL vs code extensions if necessary
#$codeextensions = code --list-extensions
#foreach ($extension in $codeextensions) {
#	code --uninstall-extension $extension
#}

# Optimise Windows with Chris Titus script - manual thing (long term goal - extract commands this is doing direct into this script)
Set-Location $env:USERPROFILE\Documents
Invoke-RestMethod christitus.com/win > winutil.ps1
Invoke-Expression .\winutil.ps1

# Clean up Windows 11 image
Dism.exe /Online /Cleanup-Image /StartComponentCleanup /RestoreHealth

# Enable Remote Desktop
Enable-NetFirewallRule -Group '@FirewallAPI.dll,-28752' | Out-Null

# restart windows to apply changes
Restart-Computer -Force
