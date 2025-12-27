# prometheus
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm show values prometheus-community/kube-prometheus-stack \
  --version 80.7.0 > values-default.yaml

helm template prometheus prometheus-community/kube-prometheus-stack \
  --version 80.7.0 \
  -n monitoring \
  -f values-custom.yaml \
  > install.yaml
```
