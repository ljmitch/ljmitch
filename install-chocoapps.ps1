# Setup a new computer with my common apps using chocolatey

# Invoke-WebRequest -Uri https://raw.githubusercontent.com/ljmitch/ljmitch/main/install-chocoapps.ps1 -OutFile .\install-chocoapps.ps1; .\install-chocoapps.ps1

$appsUrl = "https://raw.githubusercontent.com/ljmitch/ljmitch/main/apps.txt"
$appList = Invoke-RestMethod -Uri $appsUrl
$appListArray = $appList -split "`r`n" | ConvertFrom-Csv
$dismAppsUrl = "https://raw.githubusercontent.com/ljmitch/ljmitch/main/dismAppList.txt"
$dismAppList = "" #Invoke-RestMethod -Uri $dismAppsUrl
$dismAppListArray = $dismAppList -split "`r`n" | ConvertFrom-Csv

# Check if chocolatey is installed
if ([string]::IsNullOrWhiteSpace($appList) -eq $false -or [string]::IsNullOrWhiteSpace($dismAppList) -eq $false)
{
    try{
        choco config get cacheLocation
    }catch{
        Write-Output "Chocolatey not detected, trying to install now"
        Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        choco feature enable -n allowGlobalConfirmation
    }
}

# Install $appList
if ([string]::IsNullOrWhiteSpace($appList) -eq $false){   
    Write-Host "Chocolatey Apps Specified"  
    foreach ($app in $appListArray.appList) {
        Write-Host "Installing app: $app"
        choco install $app /y | Write-Output
    }
}

# Install $dismAppList
if ([string]::IsNullOrWhiteSpace($dismAppList) -eq $false){
    Write-Host "DISM Features Specified"    
    foreach ($app in $dismAppListArray.appList) {
        Write-Host "Installing dism feature: $app"
        & choco install $app /y /source windowsfeatures | Write-Output
    }
}
