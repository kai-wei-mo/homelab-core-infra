# cert-manager

Issues and renews TLS certificates in-cluster. Used for the Let's Encrypt
wildcard cert for `*.home.chaewon.io` via the DNS-01 challenge (Cloudflare),
since those hostnames resolve to a Tailscale IP that Let's Encrypt can't reach.

## Regenerate `install.yaml`

Chart version and render flags live in [`helm.yaml`](helm.yaml).

```bash
./scripts/render-helm.sh cert-manager
```

