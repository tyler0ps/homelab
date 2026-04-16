resource "proxmox_vm_qemu" "talos" {
  for_each = local.talos_nodes

  agent = 1
  boot  = "order=virtio0;ide2;net0"
  cpu { cores = 2 }
  memory      = 4096
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
          size    = "30G"
          storage = "local"
        }
      }
    }
  }

  network {
    bridge = "vmbr0"
    id     = 0
    model  = "virtio"
  }
}
