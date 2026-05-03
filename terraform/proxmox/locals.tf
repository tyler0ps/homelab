locals {
  talos_nodes = {
    "controlplane-01" = {
      target_node  = "node01",
      role         = "controlplane",
      disk_size    = "20G",
      disk_storage = "local",
      cpu          = "2",
      memory       = "4096"
    }

    "worker-01" = {
      target_node  = "tylerops",
      role         = "worker",
      disk_size    = "100G",
      disk_storage = "local",
      cpu          = "4",
      memory       = "16384"
    }

    "worker-02" = {
      target_node  = "tylerops",
      role         = "worker",
      disk_size    = "100G",
      disk_storage = "nvme-data"
      cpu          = "4",
      memory       = "16384"
    }

    "worker-03" = {
      target_node  = "node02",
      role         = "worker",
      disk_size    = "50G",
      disk_storage = "local-lvm",
      cpu          = "4",
      memory       = "8192"
    }
  }
}
