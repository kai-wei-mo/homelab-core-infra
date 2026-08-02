# plane

Plane Community Edition — self-hosted issue tracking (Jira-like).

- **URL**: https://plane.home.chaewon.io (Tailscale / `*.home.chaewon.io`)
- **TLS / routes**: chart ingress is off; see [`ingressroute.yaml`](ingressroute.yaml) + [`middlewares.yaml`](middlewares.yaml). Prefer **https://plane.home.chaewon.io/god-mode/** (trailing slash).
- **Basename**: [`patch-admin-hydrate.yaml`](patch-admin-hydrate.yaml) injects a `location.replace` so bare `/god-mode` becomes `/god-mode/` before React Router loads (basename is `/god-mode/`).
- **WEB_URL**: [`patch-web-url.yaml`](patch-web-url.yaml) overrides the chart’s hardcoded `http://` `WEB_URL` / CORS to `https://`
- **Hydration**: [`patch-web-hydrate.yaml`](patch-web-hydrate.yaml) strips the empty React root (React #418); bump init image tags when changing `planeVersion`
- **Secrets**: `sealed-plane-*-secrets.yaml` (one SealedSecret per file) for app, Postgres, RabbitMQ, MinIO, and live service credentials. Chart `external_secrets.*` points at those Secret names.

## Regenerate `install.yaml`

Chart version and render flags live in [`helm.yaml`](helm.yaml).

```bash
./scripts/render-helm.sh plane
```
