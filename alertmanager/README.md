# alertmanager

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm show values prometheus-community/alertmanager \
  --version 1.33.1 > values-default.yaml

helm template alertmanager prometheus-community/alertmanager \
  --version 1.33.1 \
  -n monitoring \
  -f values-custom.yaml \
  > install.yaml

# values.yaml: https://github.com/prometheus-community/helm-charts/blob/main/charts/alertmanager/values.yaml
```

## Wise USD/CAD exchange rate alert

AlertmanagerConfig, PrometheusRule, and ServiceMonitor for alerting when the Wise USD→CAD rate exceeds 1.37 (sends to Discord).

### Prerequisites

1. **Discord webhook secret**
   ```bash
   kubectl create secret generic wise-discord-webhook -n monitoring \
     --from-literal=url='https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_TOKEN'
   ```

2. **AlertmanagerConfig usage**  
   AlertmanagerConfig is applied by Prometheus Operator when it manages Alertmanager. With `alertmanager.enabled: false` in the Prometheus stack, the standalone Alertmanager in this chart does not use AlertmanagerConfig. To use it:
   - Enable alertmanager in kube-prometheus-stack (`prometheus/values-custom.yaml`), or
   - Ensure your Alertmanager CR has `alertmanagerConfigSelector: {}` (or matching labels) and is managed by the operator.

3. **Python app** (to be implemented)  
   Deploy an app that:
   - Exposes `/metrics` in Prometheus text format
   - Exposes a gauge: `wise_usd_cad_exchange_rate` (current USD→CAD rate from Wise)
   - Has a Service with label `app: wise-exchange-rate` and a port named `http`
