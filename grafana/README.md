# grafana

```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm show values grafana/grafana \
  --version 10.4.0 > values-default.yaml

helm template grafana grafana/grafana \
  --version 10.4.0 \
  -f values-custom.yaml \
  > install.yaml

# values.yaml: https://github.com/grafana-community/helm-charts/blob/main/charts/grafana/values.yaml
```
