$appsUrl = "https://raw.githubusercontent.com/ljmitch/ljmitch/main/apps.txt"
$appList = Invoke-RestMethod -Uri $appsUrl
$appListArray = $appList -split "`r`n" | ConvertFrom-Csv
$dismAppsUrl = "https://raw.githubusercontent.com/ljmitch/ljmitch/main/dismAppList.txt"
$dismAppList = Invoke-RestMethod -Uri $dismAppsUrl
$dismAppListArray = ""

# Check if chocolatey is installed
if ([string]::IsNullOrWhiteSpace($appListArray) -eq $false -or [string]::IsNullOrWhiteSpace($dismAppListArray) -eq $false)
{
    try{
        choco config get cacheLocation
    }catch{
        Write-Output "Chocolatey not detected, trying to install now"
        iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        choco feature enable -n allowGlobalConfirmation

    }
}

# Install appList
if ([string]::IsNullOrWhiteSpace($appListArray) -eq $false){   
    Write-Host "Chocolatey Apps Specified"  
    foreach ($app in $appListArray.appList) {
        Write-Host "Installing app: $app"
        choco install $app /y | Write-Output
    }
}

# Install dismAppList
if ([string]::IsNullOrWhiteSpace($dismAppListArray) -eq $false){
    Write-Host "DISM Features Specified"    
    foreach ($app in $dismAppListArray.appList) {
        Write-Host "Installing dism feature: $app"
        & choco install $app /y /source windowsfeatures | Write-Output
    }
}
