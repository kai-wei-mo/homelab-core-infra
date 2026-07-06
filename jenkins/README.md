# jenkins

```bash
helm repo add jenkins https://charts.jenkins.io
helm repo update

helm show values jenkins/jenkins \
  --version 5.9.32 \
  > values-default.yaml

helm template jenkins jenkins/jenkins \
  --version 5.9.32 \
  -n jenkins \
  -f values-custom.yaml \
  > install.yaml

# values.yaml: https://github.com/jenkinsci/helm-charts/blob/main/charts/jenkins/values.yaml
```

## Admin credentials

Admin user/password come from SealedSecret `jenkins-admin` (keys `jenkins-admin-user`, `jenkins-admin-password`).
Keep `controller.admin.createSecret: true` with `existingSecret` so the chart mounts those keys as JCasC `chart-admin-*` files without rendering a Secret.

```bash
kubectl create secret generic jenkins-admin -n jenkins \
  --from-literal=jenkins-admin-user=admin \
  --from-literal=jenkins-admin-password='<strong-password>' \
  --dry-run=client -o yaml | kubeseal -o yaml > sealed-jenkins-admin.yaml
```

## Access

- URL: https://jenkins.home.chaewon.io (tailnet-only)
