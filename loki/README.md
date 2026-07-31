# loki

Monolithic Loki with 14d retention, chunks on local MinIO (`minio` namespace).

## Regenerate `install.yaml`

Chart version and render flags live in [`helm.yaml`](helm.yaml).

```bash
./scripts/render-helm.sh loki
```

