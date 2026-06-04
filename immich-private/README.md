# immich-private

A second [Immich](https://immich.app/) (self-hosted photos) instance on Kubernetes, independent from `immich`. Same layout: official Helm chart plus CloudNativePG for PostgreSQL with VectorChord. Runs in its own `immich-private` namespace with its own database, Valkey, and library, served at `immich-private.home.chaewon.io` (tailnet-only).

## Prerequisites

- **CloudNative-PG** Application synced first ([`argocd/applications/cloudnative-pg.yaml`](../argocd/applications/cloudnative-pg.yaml)); this Argo CD Application uses sync wave `1` so the operator is already on the cluster.
- **TLS**: Ingress references `home-chaewon-io-wildcard` for `immich-private.home.chaewon.io`. Reflector mirrors that secret into new namespaces (including `immich-private`).
- **Database password**: [`sealed-db-owner-secret.yaml`](sealed-db-owner-secret.yaml) (Sealed Secret) supplies credentials for CNPG bootstrap and Immich `DB_*` env vars. This reuses the same credentials as `immich` (same `immich-private-database-owner-secret`), but bootstraps a separate `immich-private` database in the `immich-private-database` cluster. If your Sealed Secret was sealed with strict (namespace-bound) scope, re-seal it for the `immich-private` namespace; cluster-wide / namespace-wide scoped secrets can be reused as-is.

## Regenerate `install.yaml`

```bash
helm show values oci://ghcr.io/immich-app/immich-charts/immich \
  --version 0.12.0 \
  > values-default.yaml

helm template immich-private oci://ghcr.io/immich-app/immich-charts/immich \
  --version 0.12.0 \
  -n immich-private \
  -f values-custom.yaml \
  > install.yaml

# Chart repo: https://github.com/immich-app/immich-charts
```

## Storage

- **Library (`/data`, writable)**: Static **hostPath** bind: [`library-pv.yaml`](library-pv.yaml) + [`library-pvc.yaml`](library-pvc.yaml). This is Immich's own writable data store — uploads, thumbnails, encoded videos, and metadata it generates (including for external assets). Host directory is `/var/lib/immich2` (`DirectoryOrCreate`, `5Gi`); change `spec.hostPath.path` and matching `capacity` for another location/size. The Immich server pod must run on the node that has that directory.
- **External library (read-only)**: [`external-library-pv.yaml`](external-library-pv.yaml) + [`external-library-pvc.yaml`](external-library-pvc.yaml) bind the existing media at host path `/mnt/seagate/immich2` (`ReadOnlyMany`). It is mounted into the `immich-private-server` pod at the same path `/mnt/seagate/immich2` (read-only) by [`patch-external-library.yaml`](patch-external-library.yaml). The upstream Immich Helm chart only renders the `library` volume and silently drops any extra persistence entries, so this mount is injected via a kustomize patch rather than `values-custom.yaml` — that way it survives every `helm template` re-render of `install.yaml`. Immich does **not** auto-import this; you must register it once in the UI (see below).
- **Postgres**: [`postgres-cluster.yaml`](postgres-cluster.yaml) requests `5Gi` from the **default StorageClass**. The DB only stores asset metadata and CLIP/face embeddings (not the media itself), so this is plenty for a personal library. CNPG volumes can be expanded later but not shrunk, so start small and grow if needed.
- **Valkey**: The rendered chart creates `immich-private-valkey` via dynamic provisioning.

## Register the external library

After the instance is up:

1. Open the Immich web UI → **Administration → Libraries → Create Library** (External).
2. Set the **import path** to `/mnt/seagate/immich2` (the in-container mount path, which here matches the host path).
3. **Scan** the library. Immich indexes the originals in place (read-only) and writes thumbnails/derived data to its own `/data` store.

The originals are mounted read-only, so Immich can browse but never modifies or deletes the source files. The mount is defined in [`patch-external-library.yaml`](patch-external-library.yaml).

## First-time sync order

Within this folder, Argo CD sync waves order resources: library PVC and DB owner secret (`-2`), Postgres `Cluster` (`-1`), then rendered Helm manifests (default `0`). The Immich server may restart until Postgres is ready; startup probes handle that.
