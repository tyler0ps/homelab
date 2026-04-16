terraform {
  required_version = ">= 1.7"

  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.2-rc07"
    }
  }

  backend "s3" {
    bucket       = "generic-gha-terraform-state"
    key          = "foundation/homelab/terraform.tfstate"
    region       = "ap-southeast-1"
    encrypt      = true
    use_lockfile = true
  }
}
provider "proxmox" {
  pm_tls_insecure = true
}
