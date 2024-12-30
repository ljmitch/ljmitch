sudo apt-get update -y && sudo apt-get upgrade -y

# Install Docker
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker

# Pull latest coder image
sudo docker pull ghcr.io/coder/coder:latest

# Create data directory and run coder container
export CODER_DATA=$HOME/.config/coderv2-docker
mkdir -p $CODER_DATA
sudo docker run --rm -it -v $CODER_DATA:/home/coder/.config -v /var/run/docker.sock:/var/run/docker.sock --group-add $(getent group docker | cut -d: -f3) ghcr.io/coder/coder:latest

# Now you can use code-server and other utils via docker containers. Alternatively you can install directly on guest OS using commands below for a selection of useful tools (for me at least!).

# Install commands below if you want to install directly on guest OS and not in a docker container

# Install Azure CLI
sudo apt-get install apt-transport-https ca-certificates curl gnupg lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -sLS https://packages.microsoft.com/keys/microsoft.asc |   gpg --dearmor | sudo tee /etc/apt/keyrings/microsoft.gpg > /dev/null
sudo chmod go+r /etc/apt/keyrings/microsoft.gpg
AZ_DIST=$(lsb_release -cs)
echo "Types: deb
URIs: https://packages.microsoft.com/repos/azure-cli/
Suites: ${AZ_DIST}
Components: main
Architectures: $(dpkg --print-architecture)
Signed-by: /etc/apt/keyrings/microsoft.gpg" | sudo tee /etc/apt/sources.list.d/azure-cli.sources
sudo apt-get update
sudo apt-get install azure-cli

# Install Hashicorp tools
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt install terraform packer

# Install PowerShell
sudo apt-get install -y wget apt-transport-https software-properties-common
source /etc/os-release
wget -q https://packages.microsoft.com/config/ubuntu/$VERSION_ID/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
sudo apt-get update
sudo apt-get install -y powershell

# Install Code Server directly to guest OS (if you do not want to run it as a docker container)
curl -fsSL https://code-server.dev/install.sh | sh
code-server
sudo systemctl enable --now code-server@$USER
sudo systemctl start code-server
sudo systemctl status code-server@$USER
sudo systemctl stop code-server@$USER
vim /home/ljmitch/.config/code-server/config.yaml
cat /home/ljmitch/.config/code-server/config.yaml

# Move to PowerShell (again if you want to run stuff directly on guest OS and not in a docker container)
pwsh

Set-PSRepository -Name "PSGallery" -InstallationPolicy "Trusted"

# Install Azure PowerShell
Install-Module -Name Az

Update-Help -UICulture en-US

# List of vscode extensions to install (if running code-server locally)
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

foreach ($extension in $extensions) { code-server --install-extension $extension }
