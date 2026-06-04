# Ingress controllers and DNS

This repo uses **Traefik** for most ingresses (grafana, health, jellyfin, plex, prometheus, price-watcher). Argo CD's ingress is applied by Ansible with no `ingressClassName`; on k3s the default class is usually Traefik, so it's served by the same controller.

## Hostname scheme

- **`*.home.chaewon.io` — tailnet-only.** A public wildcard A record at Cloudflare
  (`*.home` → the k3s node's Tailscale IP, `100.112.46.91`, DNS only / grey cloud)
  resolves everywhere, but the IP is only reachable from devices on the tailnet.
  No local DNS server or `/etc/hosts` entries needed.
- **`health.chaewon.io`, `immich.chaewon.io`, `jellyfin.chaewon.io`,
  `plex.chaewon.io` — public.** Reach the cluster through the Cloudflare tunnel
  (`cloudflare-tunnel-remote`); the ingress has a rule for both the public and
  the `.home.` hostname.

The Tailscale IP is sticky for the lifetime of the node's registration; it only
changes if the machine is deleted from the tailnet and re-added (in which case,
update the wildcard record).

## Inspect ingress controllers and classes

Run against your cluster (e.g. `kubectl` or `k3s kubectl`).

**IngressClasses (which controllers exist):**

```bash
kubectl get ingressclass -o wide
```

Look for `traefik` and whether any class is marked **default** (`ADMISSION` or default annotation).

**Ingresses and which class they use:**

```bash
kubectl get ingress -A -o custom-columns='NAMESPACE:.metadata.namespace,NAME:.metadata.name,HOSTS:.spec.rules[*].host,CLASS:.spec.ingressClassName'
```

**Traefik pods (if Traefik is in-cluster):**

```bash
kubectl get pods -A -l app.kubernetes.io/name=traefik
```

## If a host like price-watcher.home.chaewon.io doesn't work

1. **Resolution:** `dig +short price-watcher.home.chaewon.io` should return the
   node's Tailscale IP (from the wildcard record). If not, check the Cloudflare
   DNS record.
2. **Reachability:** the client must be on the tailnet (Tailscale connected).
   `tailscale ping xps13-9350` to confirm.
3. **Routing:** `kubectl get ingress -A` must show the host. Ingress only routes
   traffic that already reaches the cluster; the Tailscale IP lands on the node,
   where Traefik listens on 80/443.

## Quick checklist for a new *.home.chaewon.io host

- [ ] Ingress has `ingressClassName: traefik` and Traefik annotations (see e.g. `health/ingress.yaml`).
- [ ] Ingress is in the same namespace as the Service it targets.
- [ ] `kubectl get ingress -A` shows the new host.
- [ ] Nothing else: the wildcard DNS record covers every `*.home.chaewon.io` name.
