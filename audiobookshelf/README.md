# audiobookshelf

```bash
helm repo add k8s-home-lab https://k8s-home-lab.github.io/helm-charts/
helm repo update

helm show values k8s-home-lab/audiobookshelf \
  --version 2.0.1 \
  > values-default.yaml

helm template audiobookshelf k8s-home-lab/audiobookshelf \
  --version 2.0.1 \
  -n audiobookshelf \
  -f values-custom.yaml \
  > install.yaml

# Upstream chart: https://github.com/k8s-home-lab/helm-charts
# Common library values: https://github.com/k8s-at-home/library-charts/blob/main/charts/stable/common/values.yaml
```

Host data lives under `/mnt/seagate/audiobookshelf` on the node, mounted at `/data` in the pod. App config and metadata use `CONFIG_PATH=/data/config` and `METADATA_PATH=/data/metadata`; add library folders under the same host tree (for example `/mnt/seagate/audiobookshelf/audiobooks`) and point Audiobookshelf at the matching path inside the container (for example `/data/audiobooks`).
