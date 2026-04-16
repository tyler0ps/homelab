locals {
  talos_nodes = {
    "controlplane-01" = { target_node = "tylerops" }
    "controlplane-02" = { target_node = "tylerops" }
    "controlplane-03" = { target_node = "tylerops" }
    "worker-01"       = { target_node = "tylerops" }
    "worker-02"       = { target_node = "tylerops" }
  }
}
