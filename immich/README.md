# immich

[Immich](https://immich.app/) (self-hosted photos) on Kubernetes: official Helm chart plus CloudNativePG for PostgreSQL with VectorChord.

## Prerequisites

- **CloudNative-PG** Application synced first ([`argocd/applications/cloudnative-pg.yaml`](../argocd/applications/cloudnative-pg.yaml)); this Argo CD Application uses sync wave `1` so the operator is already on the cluster.
- **TLS**: Ingress references `kwm-local-wildcard` for `immich.kwm.local`. Reflector is configured to mirror that secret into new namespaces (including `immich`).
- **Database password**: [`sealed-db-owner-secret.yaml`](sealed-db-owner-secret.yaml) (Sealed Secret) supplies credentials for CNPG bootstrap and Immich `DB_*` env vars. To rotate after bootstrap, re-seal with [kubeseal](https://github.com/bitnami-labs/sealed-secrets), sync, `ALTER USER immich WITH PASSWORD '…'` in Postgres, then restart Immich workloads. Changing the secret alone only affects a not-yet-bootstrapped `Cluster`.

### Rotate after a leak (existing cluster)

1. Generate and seal a new secret (do not commit cleartext):

```bash
kubectl create secret generic immich-database-owner-secret \
  --namespace=immich \
  --from-literal=username=immich \
  --from-literal=password="$(openssl rand -hex 24)" \
  --dry-run=client -o yaml | kubeseal -o yaml > sealed-db-owner-secret.yaml
```

2. Commit, push, and let Argo CD sync (removes the plain `Secret`, applies `SealedSecret`).
3. After sync, update Postgres and restart Immich:

```bash
NEW=$(kubectl get secret immich-database-owner-secret -n immich -o jsonpath='{.data.password}' | base64 -d)
kubectl exec -n immich immich-database-1 -- psql -U postgres -c "ALTER USER immich WITH PASSWORD '$NEW';"
kubectl rollout restart deployment/immich-server -n immich
```

If the SealedSecret reports the Secret already exists, delete the old Argo-managed `Secret` once after sync so the controller can recreate it.

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
