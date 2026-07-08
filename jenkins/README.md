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
  -f plugins.yaml \
  > install.yaml

# values.yaml: https://github.com/jenkinsci/helm-charts/blob/main/charts/jenkins/values.yaml
```
