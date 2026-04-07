# terraria (tModLoader)

This app deploys a tModLoader dedicated server on Kubernetes using Argo CD + Kustomize.

It follows the upstream dedicated server Docker guidance:
- Persistent data mounted at `/tModLoader`
- `serverconfig.txt` used for non-interactive startup
- Game port `7777/TCP` exposed for players

Upstream docs: https://docs.tmodloader.net/docs/stable/md__github_workspace_src_t_mod_loader__terraria_release_extras__dedicated_server_utils__r_e_a_d_m_e.html

## Build and push the image

The upstream docs provide a Dockerfile and compose setup, but they do not publish a canonical image tag for direct Kubernetes use. Build from the official Dockerfile and push to your registry.

```bash
TMPDIR="$(mktemp -d)"
cd "$TMPDIR"

git clone --depth=1 --branch 1.4.4 https://github.com/tModLoader/tModLoader.git
cd tModLoader/patches/tModLoader/Terraria/release_extras/DedicatedServerUtils

docker build -t ghcr.io/kai-wei-mo/tmodloader-server:v2026.01 .
docker push ghcr.io/kai-wei-mo/tmodloader-server:v2026.01
```

If your image tag changes, update `deployment.yaml`.

## Public exposure (direct NAT)

This app uses a `LoadBalancer` service on `7777/TCP`. Configure your router/firewall to forward external `7777/TCP` to the cluster LoadBalancer IP shown by:

```bash
kubectl -n terraria get svc terraria -o wide
```

## Mods and world files

The PVC mounted at `/tModLoader` persists server data. The expected structure aligns with upstream docs (`Mods`, `Worlds`, `server`, `steamapps`, `logs`, and `serverconfig.txt`).

For Steam workshop mods, this app now mounts:
- `terraria/install.txt` -> `/tModLoader/Mods/install.txt`
- `terraria/enabled.json` -> `/tModLoader/Mods/enabled.json`

Update those two repo files and restart/sync the app to apply mod changes.
