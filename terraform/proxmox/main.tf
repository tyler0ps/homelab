resource "proxmox_vm_qemu" "talos" {
  for_each = local.talos_nodes

  agent              = 1
  start_at_node_boot = true
  boot               = "order=virtio0;ide2;net0"

  cpu { cores = each.value.cpu }
  memory      = each.value.memory
  name        = each.key
  scsihw      = "virtio-scsi-single"
  target_node = each.value.target_node

  disks {
    ide {
      ide2 {
        cdrom {
          iso = "local:iso/metal-amd64.iso"
        }
      }
    }

    virtio {
      virtio0 {
        disk {
          cache   = "writeback"
          size    = each.value.disk_size
          storage = each.value.disk_storage
        }
      }
    }
  }

  network {
    bridge = "vmbr0"
    id     = 0
    model  = "virtio"
  }

  lifecycle {
    ignore_changes = [startup_shutdown]
  }
}
