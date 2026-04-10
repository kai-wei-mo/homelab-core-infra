# qbittorrent

```bash
helm repo add k8s-home-lab https://k8s-home-lab.github.io/helm-charts/
helm repo update

helm show values k8s-home-lab/qbittorrent \
  --version 14.4.0 \
  > values-default.yaml

helm template qbittorrent k8s-home-lab/qbittorrent \
  --version 14.4.0 \
  -n qbittorrent \
  -f values-custom.yaml \
  > install.yaml

# values.yaml: https://github.com/k8s-home-lab/helm-charts/blob/master/charts/stable/qbittorrent/values.yaml
```
