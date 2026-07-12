# loki

Monolithic Loki with 14d retention, chunks on local MinIO (`minio` namespace).

```bash
helm repo add grafana-community https://grafana-community.github.io/helm-charts
helm repo update

helm show values grafana-community/loki \
  --version 18.4.4 > values-default.yaml

helm template loki grafana-community/loki \
  --version 18.4.4 \
  -n logging \
  -f values-custom.yaml \
  --api-versions monitoring.coreos.com/v1 \
  > install.yaml

# values.yaml: https://github.com/grafana-community/helm-charts/blob/main/charts/loki/values.yaml
```
