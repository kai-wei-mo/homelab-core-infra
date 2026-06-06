# cert-manager

Issues and renews TLS certificates in-cluster. Used for the Let's Encrypt
wildcard cert for `*.home.chaewon.io` via the DNS-01 challenge (Cloudflare),
since those hostnames resolve to a Tailscale IP that Let's Encrypt can't reach.

```bash
helm repo add jetstack https://charts.jetstack.io
helm repo update

helm show values jetstack/cert-manager \
  --version v1.20.3 > values-default.yaml

helm template cert-manager jetstack/cert-manager \
  --version v1.20.3 \
  --include-crds \
  -n cert-manager \
  -f values-custom.yaml \
  > install.yaml

# values.yaml: https://github.com/cert-manager/cert-manager/blob/master/deploy/charts/cert-manager/values.yaml
```
