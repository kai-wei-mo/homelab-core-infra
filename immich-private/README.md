# immich-private

[Immich](https://immich.app/) (self-hosted photos) on Kubernetes: official Helm chart plus CloudNativePG for PostgreSQL with VectorChord.


## Prerequisites

- **CloudNative-PG** Application synced first ([`argocd/applications/cloudnative-pg.yaml`](../argocd/applications/cloudnative-pg.yaml)); this Argo CD Application uses sync wave `1` so the operator is already on the cluster.
- **TLS**: Ingress references `home-chaewon-io-wildcard` for `immich-private.home.chaewon.io`. Reflector is configured to mirror that secret into new namespaces (including `immich-private`).
- **Database password**: [`sealed-db-owner-secret.yaml`](sealed-db-owner-secret.yaml) (Sealed Secret) supplies credentials for CNPG bootstrap and Immich `DB_*` env vars. To rotate after bootstrap, re-seal with [kubeseal](https://github.com/bitnami-labs/sealed-secrets), sync, `ALTER USER immich WITH PASSWORD '…'` in Postgres, then restart Immich workloads. Changing the secret alone only affects a not-yet-bootstrapped `Cluster`.


## Regenerate `install.yaml`

Chart version and render flags live in [`helm.yaml`](helm.yaml).

```bash
./scripts/render-helm.sh immich-private
```


## Storage

This instance is an external library. Originals stay on `/mnt/seagate/immich2` and are indexed in place. `/var/lib/immich2` stores thumbnails, transcodes, and database dumps only.


## Backup

Immich dumps the database daily at 02:00 UTC into `/data/backups`. Filenames look like `immich-private-db-backup-20261117T020000-….sql.gz`. The dump is metadata only, not the photos.

Restore a snapshot onto a machine that has the password and the access key:

```bash
restic -r s3:s3.us-east-1.amazonaws.com/kwm-immich-private-backup snapshots
restic -r s3:s3.us-east-1.amazonaws.com/kwm-immich-private-backup restore latest --target /restore
```

The files come back under `/restore/var/lib/immich2`.
