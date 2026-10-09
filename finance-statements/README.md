# finance-statements

Private statement explorer at **https://statements.home.chaewon.io** (tailnet only).

Image: `kaiweimo/finance-statements:0.2.0` (built from the `finance-statements` repo, no ledger baked in).

Ledger files come from a SealedSecret. From that repo, after `statements/` + `config/` are populated:

```bash
make seal
```

That writes gitignored `secret.yaml` here and `sealed-finance-statements-data.yaml` (commit the sealed file). Needs `kubectl` + `kubeseal` against this cluster (`sealed-secrets-controller` in `kube-system`).
