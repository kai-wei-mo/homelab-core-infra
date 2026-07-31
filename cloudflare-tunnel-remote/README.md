# cloudflared

## Regenerate `install.yaml`

Chart version and render flags live in [`helm.yaml`](helm.yaml).

```bash
./scripts/render-helm.sh cloudflare-tunnel-remote
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
