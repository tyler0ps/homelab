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
> 3 CP node IPs are .41 .42 .43
> 2 Worker node IPs are .44 .45

```bash
export CP_IP_1=192.168.1.49
export CP_IP_2=192.168.1.50
export CP_IP_3=192.168.1.46
export WK_IP_1=192.168.1.47
export WK_IP_2=192.168.1.48
```

Generate the talos configurations
```bash
talosctl gen config talos-proxmox-cluster https://${CP_IP_1}:6443 --output-dir talos --install-disk "/dev/vda" --install-image factory.talos.dev/installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.12.5 --config-patch @talos-patch.yaml
```

Update talos configs
```bash
talosctl apply-config --insecure --nodes ${CP_IP_1} --file talos/controlplane.yaml
talosctl apply-config --insecure --nodes ${CP_IP_2} --file talos/controlplane.yaml
talosctl apply-config --insecure --nodes ${CP_IP_3} --file talos/controlplane.yaml
```

Apply configs to controlplane nodes
```bash
export TALOSCONFIG="talos/talosconfig"
talosctl config endpoint ${CP_IP_1} ${CP_IP_2} ${CP_IP_3}
talosctl config node ${CP_IP_1}
```

Bootstrap etcd
```bash
talosctl bootstrap
```

Generate kubeconfig file
```bash
talosctl kubeconfig .
```

Move file, set as default kubeconfig
```bash
mv kubeconfig ~/.kube/config
```
> If needed

After bootstraping control plane nodes, add more worker nodes, VMs. Then join worker nodes to the cluster.
```bash
talosctl apply-config --insecure --nodes ${WK_IP_1} --file talos/worker.yaml
talosctl apply-config --insecure --nodes ${WK_IP_2} --file talos/worker.yaml
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