# cloudnative-pg

[CloudNativePG](https://cloudnative-pg.io/) operator. Required for Immich PostgreSQL (VectorChord image).

```bash
helm repo add cnpg https://cloudnative-pg.github.io/charts
helm repo update

helm show values cnpg/cloudnative-pg \
  --version 0.28.0 \
  > values-default.yaml

helm template cnpg cnpg/cloudnative-pg \
  --version 0.28.0 \
  -n cnpg-system \
  --include-crds \
  -f values-custom.yaml \
  > install.yaml

# values reference: https://github.com/cloudnative-pg/charts/blob/main/charts/cloudnative-pg/values.yaml
```

Sync this Application before the Immich Application (see `argocd/applications` sync-wave annotations).
