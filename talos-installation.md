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
tf apply
```

> VMs come up with DHCP IPs initially. The static IPs below are what the per-node patches in `talos-patches/` will pin them to after `apply-config`. Use the DHCP IPs (check Proxmox console → Summary) for the first apply.

```bash
export CP_IP_1=192.168.1.16
export WK_IP_1=192.168.1.47
export WK_IP_2=192.168.1.48
```

Generate the talos configurations
```bash
talosctl gen config talos-proxmox-cluster https://${CP_IP_1}:6443 --output-dir talos --install-disk "/dev/vda" --install-image factory.talos.dev/installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.12.5 --config-patch @talos-patch.yaml
```

Apply per-node config to the control plane. The patch in `talos-patches/controlplane-01.yaml` pins the static IP on `ens18`, so Talos won't drift back to DHCP after a reboot.

> If the cluster is being recovered after a DHCP IP change, replace `${CP_IP_1}` with the **current** IP of the node (check via Proxmox console → Summary). Talos will apply the config and reboot into the new static IP.

```bash
talosctl apply-config --insecure --nodes ${CP_IP_1} --file talos/controlplane.yaml --config-patch @talos-patches/controlplane-01.yaml
```

Set up talosctl context (endpoints/node used by subsequent commands)
```bash
export TALOSCONFIG="talos/talosconfig"
talosctl config endpoint ${CP_IP_1}
talosctl config node ${CP_IP_1}
```

Bootstrap etcd
```bash
talosctl bootstrap
```

Generate kubeconfig file
```bash
talosctl kubeconfig --force ~/.kube/config
```
> Use `--force` to overwrite an existing kubeconfig (e.g., when re-running after an IP change)

After bootstrapping control plane nodes, add more worker nodes, VMs. Then join worker nodes to the cluster.
```bash
talosctl apply-config --insecure --nodes ${WK_IP_1} --file talos/worker.yaml --config-patch @talos-patches/worker-01.yaml
talosctl apply-config --insecure --nodes ${WK_IP_2} --file talos/worker.yaml --config-patch @talos-patches/worker-02.yaml
```

Install Cilium and GatewayAPI
```bash
# Install GatewayAPI CRDs
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.4.1/config/crd/standard/gateway.networking.k8s.io_gatewayclasses.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.4.1/config/crd/standard/gateway.networking.k8s.io_gateways.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.4.1/config/crd/standard/gateway.networking.k8s.io_httproutes.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.4.1/config/crd/standard/gateway.networking.k8s.io_referencegrants.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.4.1/config/crd/standard/gateway.networking.k8s.io_grpcroutes.yaml

# TLSRoute
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.4.1/config/crd/experimental/gateway.networking.k8s.io_tlsroutes.yaml

# Install Cilium
helm repo add cilium https://helm.cilium.io/
helm repo update
helm install \
    cilium \
    cilium/cilium \
    --version 1.19.3 \
    --namespace kube-system \
    --set ipam.mode=kubernetes \
    --set kubeProxyReplacement=true \
    --set securityContext.capabilities.ciliumAgent="{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}" \
    --set securityContext.capabilities.cleanCiliumState="{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}" \
    --set cgroup.autoMount.enabled=false \
    --set cgroup.hostRoot=/sys/fs/cgroup \
    --set k8sServiceHost=localhost \
    --set k8sServicePort=7445 \
    --set=gatewayAPI.enabled=true \
    --set=gatewayAPI.enableAlpn=true \
    --set=gatewayAPI.enableAppProtocol=true
```

## To migrate a Talos VM to another pve node

Single CP — destroy/recreate is unsafe (loses etcd). Use Proxmox live migration instead:

```bash
# On the source pve node — eject install ISO so the disk can migrate
qm set <vmid> --ide2 none,media=cdrom

# Live-migrate VM + local disk to target pve node
qm migrate <vmid> <target-pve-node> --online --with-local-disks

# Reconcile Terraform after updating target_node in terraform/proxmox/locals.tf
cd terraform/proxmox && terraform refresh
```