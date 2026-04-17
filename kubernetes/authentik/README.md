
```bash
helm repo add goauthentik https://charts.goauthentik.io/
helm repo update
helm upgrade --install authentik goauthentik/authentik \
  --version 2026.2.2 \
  --namespace authentik \
  --create-namespace \
  -f kubernetes/authentik/values.yaml
```
