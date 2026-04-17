# CloudNativePG

## Install operator

```bash
helm repo add cnpg https://cloudnative-pg.github.io/charts
helm repo update
helm upgrade --install cnpg cnpg/cloudnative-pg \
  --namespace cnpg-system \
  --create-namespace
```

## Install local-path-provisioner
```bash
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.35/deploy/local-path-storage.yaml

kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

kubectl label namespace local-path-storage pod-security.kubernetes.io/enforce=privileged --overwrite

kubectl rollout restart deployment local-path-provisioner -n local-path-storage
```

## Deploy PostgreSQL cluster
## Create the database credentials secret

```bash
kubectl create namespace database

kubectl create secret generic app-database-credentials \
  -n database \
  --from-literal=username=appuser \
  --from-literal=password=$(openssl rand -base64 24)

kubectl apply -f kubernetes/cloudnative-pg/postgres-cluster.yaml
```

```bash
# Watch the cluster come up
kubectl get cluster postgres-cluster -n database -w

# Check the cluster status
kubectl get pods -l cnpg.io/cluster=postgres-cluster -n database

# View detailed cluster information
kubectl describe cluster postgres-cluster -n database

# Check which pod is the primary
kubectl get pods -l cnpg.io/cluster=postgres-cluster -l role=primary -n database

# List the services created for the cluster
kubectl get svc -l cnpg.io/cluster=postgres-cluster -n database

# postgres-cluster-r    ClusterIP   10.98.195.226  - connects to any instance (read)
# postgres-cluster-ro   ClusterIP   10.104.18.109  - connects to replicas (read-only)
# postgres-cluster-rw   ClusterIP   10.106.51.7    - connects to the primary (read-write)
```

```bash
kubectl run psql-test --rm -it \
  --namespace database \
  --image=postgres:16.2 \
  --env="PGPASSWORD=$(kubectl get secret app-database-credentials -n database -o jsonpath='{.data.password}' | base64 -d)" \
  -- psql -h postgres-cluster-rw -U appuser -d appdb -c "SELECT version();"
```

# TODO: Backup to NAS
# TODO: When having more nodes, test failover