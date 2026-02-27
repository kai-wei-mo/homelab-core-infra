# cloudflared

```bash
helm repo add cloudflare https://cloudflare.github.io/helm-charts
helm repo update

helm show values cloudflare/cloudflare-tunnel-remote \
  --version 0.1.2 \
  > values-default.yaml

helm template plex cloudflare/cloudflare-tunnel-remote \
  --version 0.1.2 \
  -f values-custom.yaml \
  > install.yaml

# values.yaml: https://github.com/cloudflare/helm-charts/blob/main/charts/cloudflare-tunnel-remote/values.yaml
```


Step 0 — Create Tunnel (once, locally)

On your laptop:

cloudflared tunnel login
cloudflared tunnel create homelab

This creates:

~/.cloudflared/<TUNNEL_ID>.json

Save:

Tunnel ID

credentials JSON file

Step 1 — Create Kubernetes Secret

In your cluster:

kubectl create secret generic cloudflared-credentials \
  --from-file=credentials.json=<PATH_TO_JSON> \
  -n kube-system
