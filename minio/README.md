# minio

Standalone MinIO on a local PVC (S3-compatible API for Loki). Data stays on-cluster disk via the default StorageClass.

## Regenerate `install.yaml`

Chart version and render flags live in [`helm.yaml`](helm.yaml).

```bash
./scripts/render-helm.sh minio
```

