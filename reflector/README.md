# reflector

```bash
helm repo add emberstack https://emberstack.github.io/helm-charts
helm repo update

helm show values emberstack/reflector \
  --version 10.0.15 > values-default.yaml

helm template reflector emberstack/reflector \
  --version 10.0.15 \
  --include-crds \
  -n monitoring \
  -f values-custom.yaml \
  > install.yaml
```
