# sealed-secrets

```bash
helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets
helm repo update

helm show values sealed-secrets/sealed-secrets \
  --version 2.18.3 \
  > values-default.yaml

helm template sealed-secrets sealed-secrets/sealed-secrets \
  --version 2.18.3 \
  --include-crds \
  -f values-custom.yaml \
  > install.yaml

# values.yaml: https://github.com/bitnami/charts/blob/main/bitnami/sealed-secrets/values.yaml
```
