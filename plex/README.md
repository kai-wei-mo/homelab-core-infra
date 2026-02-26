# plex

```bash
helm repo add k8s-home-lab https://k8s-home-lab.github.io/helm-charts/
helm repo update

helm show values k8s-home-lab/plex \
  --version 7.3.0 \
  > values-default.yaml

helm template plex k8s-home-lab/plex \
  --version 7.3.0 \
  -f values-custom.yaml \
  > install.yaml

# values.yaml:
# - https://github.com/k8s-home-lab/helm-charts/blob/master/charts/stable/plex/values.yaml
# - https://github.com/k8s-at-home/library-charts/tree/main/charts/stable/common/values.yaml
```
