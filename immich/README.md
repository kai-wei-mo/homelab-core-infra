# immich

[Immich](https://immich.app/) (self-hosted photos) on Kubernetes: official Helm chart plus CloudNativePG for PostgreSQL with VectorChord.

## Prerequisites

- **CloudNative-PG** Application synced first ([`argocd/applications/cloudnative-pg.yaml`](../argocd/applications/cloudnative-pg.yaml)); this Argo CD Application uses sync wave `1` so the operator is already on the cluster.
- **TLS**: Ingress references `kwm-local-wildcard` for `immich.kwm.local`. Reflector is configured to mirror that secret into new namespaces (including `immich`).
- **Database password**: [`db-owner-secret.yaml`](db-owner-secret.yaml) contains a generated password used for both CNPG bootstrap and Immich `DB_*` env vars. Rotate it (and re-seal with [Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets) if you prefer not to store cleartext in Git), then reconcile the `Cluster` only if you change it before first bootstrap.

## Regenerate `install.yaml`

```bash
helm show values oci://ghcr.io/immich-app/immich-charts/immich \
  --version 0.11.1 \
  > values-default.yaml

helm template immich oci://ghcr.io/immich-app/immich-charts/immich \
  --version 0.11.1 \
  -n immich \
  -f values-custom.yaml \
  > install.yaml

# Chart repo: https://github.com/immich-app/immich-charts
```

## Storage

- **Library**: Static **hostPath** bind: [`library-pv.yaml`](library-pv.yaml) + [`library-pvc.yaml`](library-pvc.yaml). The PVC binds immediately to the PV (no dynamic provisioner, no `WaitForFirstConsumer`). Default host directory is `/var/lib/immich` (`DirectoryOrCreate`); change `spec.hostPath.path` and matching `capacity` if you want another location or size. The Immich server pod must run on the node that has that directory (single-node clusters are fine; multi-node needs node affinity or shared storage).
- **Postgres**: [`postgres-cluster.yaml`](postgres-cluster.yaml) still requests `20Gi` from the **default StorageClass**. If that PVC also sticks on `WaitForFirstConsumer` or never provisions, add another static PV/PVC pair or install a provisioner; CNPG can reference a storage class via `spec.storage.storageClass`.
- **Valkey**: The rendered chart still creates `immich-valkey` via dynamic provisioning. If that PVC pending event is what you see, either fix your default `StorageClass` or we can switch Valkey to `emptyDir` in `values-custom.yaml` (queue not persisted across restarts).

## Alpine / DNS

Immich images are Alpine-based. If pods fail to resolve short Kubernetes service names when your nodes use a **search domain** in `resolv.conf`, prefer FQDNs (already set for `DB_HOSTNAME`) or apply the workaround described in [Immich Kubernetes docs](https://docs.immich.app/install/kubernetes).

## First-time sync order

Within this folder, Argo CD sync waves order resources: library PVC and DB owner secret (`-2`), Postgres `Cluster` (`-1`), then rendered Helm manifests (default `0`). The Immich server may restart until Postgres is ready; startup probes handle that.
