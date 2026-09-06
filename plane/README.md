# plane

Plane Community Edition — self-hosted issue tracking (Jira-like).

- **URL**: https://plane.home.chaewon.io
- **Setup**: https://plane.home.chaewon.io/god-mode/ (include the trailing slash)
- **TLS**: chart Traefik `IngressRoute` uses `home-chaewon-io-wildcard` (Reflector)
- **Secrets**: `sealed-plane-*-secrets.yaml`

`WEB_URL` / `CORS_ALLOWED_ORIGINS` are `https://plane.home.chaewon.io` (Plane's documented `.env` values). Traefik is the reverse proxy: browsers use 443; pods still listen on 3000/8000 inside the cluster.

Until first-time setup is done, Traefik 302s `/` → `/god-mode/` and `/god-mode` → `/god-mode/` (so nginx cannot 301 you to `:3000`). After setup, remove `plane-root-to-god-mode` from [slash-redirect.yaml](slash-redirect.yaml) and the catch-all patch in [kustomization.yaml](kustomization.yaml), or the web app home will keep bouncing to admin.

A cached browser 301 to `:3000` will still fail; use a private window.

`assign_cluster_ip: true` is required so Traefik does not 503 on `/api/*` (chart default is headless).

## Regenerate `install.yaml`

Chart version and render flags live in [`helm.yaml`](helm.yaml).

```bash
./scripts/render-helm.sh plane
```
