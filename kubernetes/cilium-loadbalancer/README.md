Upgrade cilium helm chart, enable LB
```bash
helm upgrade cilium cilium/cilium \
  --namespace kube-system \
  --reuse-values \
  --set l2announcements.enabled=true \
  --set externalIPs.enabled=true
```

```bash
k apply -f '/Users/tyler0ps/workspace/homelab/kubernetes/cilium-loadbalancer/lb-ip-pool.yaml'
k apply -f '/Users/tyler0ps/workspace/homelab/kubernetes/cilium-loadbalancer/l2-announcement.yaml'
```

```bash
helm upgrade cilium cilium/cilium \
  --namespace kube-system \
  --reuse-values \
  --set devices=""
```

## Test
Make sure is it enabled
```bash
k -n kube-system exec ds/cilium -- cilium-dbg config --all | grep EnableL2Announcements
```

if get this value, 
`EnableL2Announcements             : false`
try restarting the cilium ds
```bash
k -n kube-system rollout restart ds/cilium
```

Create service LoadBalancer type
```bash
k apply -f '/Users/tyler0ps/workspace/homelab/kubernetes/cilium-loadbalancer/test-service.yaml'
```

Get the service, expect a valid external-ip
```bash
k get svc web-app-lb
```

curl the local ip, should be able to reach the nginx
```bash
curl 192.168.1.192
```
Clean up
```bash
k delete -f kubernetes/cilium-loadbalancer/test-service.yaml
```

Next, create gateway
```bash
kubectl apply -f kubernetes/cilium-loadbalancer/gateway.yaml
kubectl apply -f kubernetes/cilium-loadbalancer/httproute-sso.yaml
kubectl get gateway main-gateway
```

Test Gateway and HTTPRoute
```bash
curl -H "Host: sso.tylerops.dev" 192.168.1.192
```