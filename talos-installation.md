Download the talos OS
```bash
https://factory.talos.dev/image/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515/v1.12.5/metal-amd64.iso
```

Upload to proxmox storage.
`local storage` -> ISO Images -> Upload

> Need add ISO image type first. 
> Datacenter -> Storage -> `local` -> Add ISO Image

Add VMs
```bash
k apply
```
> 3 CP node IPs are .41 .42 .43
> 2 Worker node IPs are .44 .45

Generate the talos configurations
```bash
talosctl gen config talos-proxmox-cluster https://192.168.1.41:6443 --output-dir talos --install-disk "/dev/vda" --install-image factory.talos.dev/installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.12.5
```

Update talos configs
```bash
talosctl apply-config --insecure --nodes 192.168.1.41 --file talos/controlplane.yaml
talosctl apply-config --insecure --nodes 192.168.1.42 --file talos/controlplane.yaml
talosctl apply-config --insecure --nodes 192.168.1.43 --file talos/controlplane.yaml
```

Apply configs to controlplane nodes
```bash
export TALOSCONFIG="talos/talosconfig"
talosctl config endpoint 192.168.1.41 192.168.1.42 192.168.1.43
talosctl config node 192.168.1.41
```

Bootstrap etcd
```bash
talosctl bootstrap
```

Generate kubeconfig file
```bash
talosctl kubeconfig .
```
> mv kubeconfig ~/.kube/config
> If needed

After bootstraping control plane nodes, add more worker nodes, VMs. Then join worker nodes to the cluster.
```bash
talosctl apply-config --insecure --nodes 192.168.1.44 --file talos/worker.yaml
talosctl apply-config --insecure --nodes 192.168.1.45 --file talos/worker.yaml
```
