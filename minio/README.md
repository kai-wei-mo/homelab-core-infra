# minio

Standalone MinIO on a local PVC (S3-compatible API for Loki). Data stays on-cluster disk via the default StorageClass.

```bash
helm show values oci://registry-1.docker.io/bitnamicharts/minio \
  --version 17.0.21 > values-default.yaml

helm template minio oci://registry-1.docker.io/bitnamicharts/minio \
  --version 17.0.21 \
  -n minio \
  -f values-custom.yaml \
  > install.yaml

# values.yaml: https://github.com/bitnami/charts/blob/main/bitnami/minio/values.yaml
```
