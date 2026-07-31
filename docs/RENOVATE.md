# Renovate

Dependency updates for this repo are handled by the [Renovate GitHub App](https://github.com/apps/renovate), plus a workflow that re-renders Helm manifests.

## One-time setup

1. Install the [Renovate GitHub App](https://github.com/apps/renovate) on [`kai-wei-mo/homelab-core-infra`](https://github.com/kai-wei-mo/homelab-core-infra) (account or org → Repository access → only this repo, or all).
2. Confirm Actions are enabled for the repo (Settings → Actions → General).
3. After the first Renovate run, check the **Dependency Dashboard** issue and any upgrade PRs.

Config lives in [`renovate.json`](../renovate.json). Onboarding is disabled because that file is already committed. `rebaseWhen: conflicted` keeps Renovate from force-pushing over the Action’s rendered `install.yaml` commits.

Immich app image tags are pinned in `kustomization.yaml` (`images:`) rather than Helm values, because the upstream chart lags Immich releases. Renovate’s built-in kustomize manager updates those tags; chart version still lives in `helm.yaml` like every other Helm app.

## How Helm upgrades work

Pattern A apps pin the chart in [`helm.yaml`](../immich/helm.yaml) (not in README prose).

1. Renovate opens a PR that bumps `version` in `helm.yaml` (and optionally Immich image tags in `values-custom.yaml`).
2. [`.github/workflows/render-helm.yml`](../.github/workflows/render-helm.yml) runs [`scripts/render-helm.sh`](../scripts/render-helm.sh) for changed apps.
3. The workflow commits updated `values-default.yaml` and `install.yaml` back to the PR branch.
4. After you merge, Argo CD syncs the kustomize path as usual.

Local regenerate:

```bash
./scripts/render-helm.sh immich
# or
./scripts/render-helm.sh --all
```

Requires `helm` and [mikefarah/yq](https://github.com/mikefarah/yq).

## Other updates

- Hand-written `deployment.yaml` image tags (fx_watcher, price_watcher, phishing, health, gluetun, qbittorrentvpn) are tracked via Renovate’s Kubernetes manager.
- Immich app tags in `immich/values-custom.yaml` and `immich-private/values-custom.yaml` are tracked separately from the chart version.
- Dashboard JSON under `grafana-dashboards/`, Argo app defs, and stubs (`harbor`, `docs`) are out of scope.
