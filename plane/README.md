# plane

Plane Community Edition — self-hosted issue tracking (Jira-like).

- **URL**: https://plane.home.chaewon.io (Tailscale / `*.home.chaewon.io`)
- **TLS**: Traefik `IngressRoute` uses `home-chaewon-io-wildcard` (mirrored by Reflector)
- **Secrets**: `sealed-plane-*-secrets.yaml` (one SealedSecret per file) for app, Postgres, RabbitMQ, MinIO, and live service credentials. Chart `external_secrets.*` points at those Secret names.

## Regenerate `install.yaml`

Chart version and render flags live in [`helm.yaml`](helm.yaml).

```bash
./scripts/render-helm.sh plane
```

## Re-seal credentials

```bash
# Fetch cert (controller: sealed-secrets-controller in kube-system)
kubeseal --fetch-cert \
  --controller-name=sealed-secrets-controller \
  --controller-namespace=kube-system \
  > /tmp/sealed-secrets-cert.pem

# Example: re-seal one secret (adjust literals; keep DATABASE_URL/AMQP_URL in sync with pg/rabbit passwords)
kubectl create secret generic plane-pgdb-secrets -n plane \
  --from-literal=POSTGRES_USER=plane \
  --from-literal=POSTGRES_DB=plane \
  --from-literal=POSTGRES_PASSWORD="$(openssl rand -hex 24)" \
  --dry-run=client -o yaml \
  | kubeseal --cert=/tmp/sealed-secrets-cert.pem -o yaml
```

Then replace the matching `sealed-plane-*-secrets.yaml` file, commit, and sync. If stateful data already exists, also update passwords inside Postgres/RabbitMQ/MinIO before restarting workloads.
