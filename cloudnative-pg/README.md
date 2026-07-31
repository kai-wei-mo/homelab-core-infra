# cloudnative-pg

[CloudNativePG](https://cloudnative-pg.io/) operator. Required for Immich PostgreSQL (VectorChord image).

## Regenerate `install.yaml`

Chart version and render flags live in [`helm.yaml`](helm.yaml).

```bash
./scripts/render-helm.sh cloudnative-pg
```


Sync this Application before the Immich Application (see `argocd/applications` sync-wave annotations).
