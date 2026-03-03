# jellyfin

```bash
helm repo add jellyfin https://jellyfin.github.io/jellyfin-helm
helm repo update

helm show values jellyfin/jellyfin \
  --version 2.7.0 \
  > values-default.yaml

helm template jellyfin jellyfin/jellyfin \
  --version 2.7.0 \
  -f values-custom.yaml \
  > install.yaml

# values.yaml: https://github.com/jellyfin/jellyfin-helm/blob/master/charts/jellyfin/values.yaml
```
