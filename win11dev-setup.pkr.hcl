packer {
  required_plugins {
    hyperv = {
      source  = "github.com/hashicorp/hyperv"
      version = "~> 1.1"
    }
  }
}

locals {
  iso_path = "C:/Users/LiamMitchell/Downloads/Downloads/26100.1742.240906-0331.ge_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-gb.iso"
}

source "hyperv-iso" "windows11" {
  iso_url      = local.iso_path
  iso_checksum = "373BABA19031BD864EF8EA0288F63CAF13F89341315A488A9318EF8EE4793286"
  //  iso_checksum_type    = "sha256"
  vm_name              = "Windows11VM"
  generation           = 2
  enable_secure_boot   = true
  secure_boot_template = "MicrosoftWindows"
  enable_tpm           = true
  cpus                 = 2
  memory               = 4096
  disk_size            = 61440
  switch_name          = "Default Switch"
  communicator         = "winrm"
  winrm_username       = "Administrator"
  winrm_password       = "Password123!"
  winrm_timeout        = "1h"
  shutdown_command     = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\""
}

build {
  sources = ["source.hyperv-iso.windows11"]

  provisioner "powershell" {
    inline = [
      "Set-ItemProperty -Path 'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Terminal Server' -Name 'fDenyTSConnections' -Value 0",
      "Set-ItemProperty -Path 'HKLM:\\System\\CurrentControlSet\\Control\\Terminal Server\\WinStations\\RDP-Tcp' -Name 'UserAuthentication' -Value 0"
    ]
  }
}