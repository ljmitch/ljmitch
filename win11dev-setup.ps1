# Install apps
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted

Install-PackageProvider -Name NuGet -Force
Install-Module -Name Az -Repository PSGallery

winget install Microsoft.WindowsTerminal.Preview
winget install Microsoft.PowerShell
winget install 7zip.7zip
winget install PuTTY.PuTTY
winget install Notepad++.Notepad++
winget install Git.Git
winget install GitHub.cli
winget install Hashicorp.Terraform
winget install Hashicorp.Packer
winget install Microsoft.AzureCLI
winget install Microsoft.Azure.AztfExport
winget install Microsoft.Bicep
winget install Microsoft.VisualStudioCode.Insiders

# Optimise Windows
Set-Location $env:USERPROFILE\Documents
#Invoke-WebRequest -useb 'https://simeononsecurity.com/scripts/windowsoptimizeanddebloat.ps1'|Invoke-Expression
Invoke-RestMethod christitus.com/win > winutil.ps1
Invoke-Expression .\winutil.ps1

$appname = "Microsoft Store"
((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | Where-Object {$_.Name -eq $appname}).Verbs() | Where-Object {$_.Name.replace('&', '') -match 'Unpin from taskbar'} | ForEach-Object {$_.DoIt()}
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "EnableAutoTray" -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchBoxTaskbarMode" -Value 0 -Type DWord
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowStartMenuApps" -Value 0

# Restart Explorer to apply changes
Stop-Process -Name explorer -Force
Start-Process explorer

## Restart Computer ##

# Git config
git config --global user.name "ljmitch"
git config --global user.email "ljmitch@gmail.com"
git config --global push.default current
git config --global push.autoSetupRemote true
git config --global pull.rebase true
git config --global core.editor code-insiders -w
git config --global init.defaultBranch main

# VS Code Extensions
code-insiders --install-extension dbaeumer.vscode-eslint --force
code-insiders --install-extension esbenp.prettier-vscode --force
code-insiders --install-extension github.vscode-pull-request-github --force
code-insiders --install-extension eamodio.gitlens-insiders --force
code-insiders --install-extension streetsidesoftware.code-spell-checker
code-insiders --install-extension ms-vscode.azure-account
code-insiders --install-extension azure-automation.vscode-azureautomation
code-insiders --install-extension ms-azuretools.vscode-azurefunctions
code-insiders --install-extension ms-vscode.azurecli
code-insiders --install-extension ms-azuretools.vscode-azureresourcegroups
code-insiders --install-extension ms-azuretools.vscode-azureterraform
code-insiders --install-extension ms-azuretools.vscode-bicep
code-insiders --install-extension fabiospampinato.vscode-diff
code-insiders --install-extension hashicorp.hcl
code-insiders --install-extension hashicorp.terraform
code-insiders --install-extension oderwat.indent-rainbow
code-insiders --install-extension visualstudioexptteam.vscodeintellicode
code-insiders --install-extension yzhang.markdown-all-in-one
code-insiders --install-extension bierner.markdown-preview-github-styles
code-insiders --install-extension ibm.output-colorizer
code-insiders --install-extension ms-vscode.powershell
code-insiders --install-extension mechatroner.rainbow-csv
code-insiders --install-extension vscode-icons-team.vscode-icons
code-insiders --install-extension redhat.vscode-yaml
code-insiders --install-extension eamodio.gitlens
code-insiders --install-extension ibm.output-colorizer
code-insiders --install-extension stkb.rewrap
code-insiders --install-extension vsls-contrib.gistfs
code-insiders --install-extension mhutchie.git-graph
code-insiders --install-extension stkb.rewrap

# Final update check
winget upgrade --all

# uninstall vs code extensions if necessary
#$codeextensions = code-insiders --list-extensions
#foreach ($extension in $codeextensions) {
#	code-insiders --uninstall-extension $extension
#}
