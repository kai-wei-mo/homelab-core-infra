# fluent-bit

Pipeline config lives in [`fluent-bit.yaml`](fluent-bit.yaml) (native Fluent Bit YAML).

```bash
helm repo add fluent https://fluent.github.io/helm-charts
helm repo update

helm show values fluent/fluent-bit \
  --version 0.57.9 > values-default.yaml

helm template fluent-bit fluent/fluent-bit \
  --version 0.57.9 \
  -n logging \
  -f values-custom.yaml \
  --set-file 'config.extraFiles.fluent-bit\.yaml=fluent-bit.yaml' \
  --api-versions monitoring.coreos.com/v1 \
  > install.yaml

# values.yaml: https://github.com/fluent/helm-charts/blob/main/charts/fluent-bit/values.yaml
```
