# node-exporter

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm show values prometheus-community/prometheus-node-exporter \
  --version 4.51.1 > values-default.yaml

helm template prometheus-node-exporter prometheus-community/prometheus-node-exporter \
  --version 4.51.1 \
  -f values-custom.yaml \
  > install.yaml

# values.yaml: https://github.com/prometheus-community/helm-charts/blob/main/charts/prometheus-node-exporter/values.yaml
```
