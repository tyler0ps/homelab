locals {
  talos_nodes = {
    "controlplane-01" = { target_node = "tylerops", role = "controlplane" }
    "controlplane-02" = { target_node = "tylerops", role = "controlplane" }
    "controlplane-03" = { target_node = "tylerops", role = "controlplane" }
    "worker-01"       = { target_node = "tylerops", role = "worker" }
    "worker-02"       = { target_node = "tylerops", role = "worker" }
  }
}
