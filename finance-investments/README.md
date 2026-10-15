# finance-investments

Private investment explorer at **https://investments.home.chaewon.io** (tailnet only).

Image: `kaiweimo/finance-investments:0.1.2` (built from the `finance-investments` repo, no statements baked in).

Performance outputs, portfolio names, and icons come from a SealedSecret. Broker statement CSVs are not included. From that repo:

```bash
make seal
```

That writes gitignored `secret.yaml` here and `sealed-finance-investments-data.yaml` (commit the sealed file). Needs `kubectl` + `kubeseal` against this cluster (`sealed-secrets-controller` in `kube-system`).
