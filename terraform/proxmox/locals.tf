locals {
  talos_nodes = {
    "controlplane-01" = { target_node = "tylerops", role = "controlplane", disk_size = "30G", disk_storage = "local" }
    "controlplane-02" = { target_node = "tylerops", role = "controlplane", disk_size = "30G", disk_storage = "local" }
    "controlplane-03" = { target_node = "tylerops", role = "controlplane", disk_size = "30G", disk_storage = "local" }
    "worker-01"       = { target_node = "tylerops", role = "worker", disk_size = "100G", disk_storage = "local" }
    "worker-02"       = { target_node = "tylerops", role = "worker", disk_size = "100G", disk_storage = "nvme-data" }
  }
}
