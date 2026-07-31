# fluent-bit

Pipeline config lives in [`fluent-bit.yaml`](fluent-bit.yaml) (native Fluent Bit YAML).

## Regenerate `install.yaml`

Chart version and render flags live in [`helm.yaml`](helm.yaml).

```bash
./scripts/render-helm.sh fluentbit
```

