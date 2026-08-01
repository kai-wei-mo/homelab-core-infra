#!/usr/bin/env bash
# Regenerate values-default.yaml and install.yaml from an app's helm.yaml.
# Usage:
#   ./scripts/render-helm.sh <app-dir> [<app-dir> ...]
#   ./scripts/render-helm.sh --all
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if ! command -v helm >/dev/null 2>&1; then
  echo "error: helm is required" >&2
  exit 1
fi
if ! command -v yq >/dev/null 2>&1; then
  echo "error: yq (mikefarah) is required" >&2
  exit 1
fi

HELM_APPS=(
  alertmanager
  audiobookshelf
  cert-manager
  cloudflare-tunnel-remote
  cloudnative-pg
  fluentbit
  grafana
  immich
  immich-private
  jellyfin
  jenkins
  loki
  minio
  node-exporter
  plex
  plane
  prometheus
  qbittorrent
  reflector
  sealed-secrets
)

render_app() {
  local app="$1"
  local dir="$ROOT/$app"
  local meta="$dir/helm.yaml"

  if [[ ! -f "$meta" ]]; then
    echo "error: missing $meta" >&2
    return 1
  fi

  echo "==> rendering $app"

  local source version releaseName namespace includeCrds
  source="$(yq -r '.source' "$meta")"
  version="$(yq -r '.version' "$meta")"
  releaseName="$(yq -r '.releaseName' "$meta")"
  namespace="$(yq -r '.namespace // ""' "$meta")"
  includeCrds="$(yq -r '.includeCrds // false' "$meta")"

  local chart_ref
  case "$source" in
    oci)
      chart_ref="$(yq -r '.chart' "$meta")"
      ;;
    repo)
      local repository repoName chart
      repository="$(yq -r '.repository' "$meta")"
      repoName="$(yq -r '.repoName' "$meta")"
      chart="$(yq -r '.chart' "$meta")"
      helm repo add "$repoName" "$repository" >/dev/null 2>&1 || true
      if ! helm repo update "$repoName" >/dev/null 2>&1; then
        echo "    warning: helm repo update failed for $repoName; using cached index" >&2
      fi
      chart_ref="${repoName}/${chart}"
      ;;
    *)
      echo "error: unknown source '$source' in $meta" >&2
      return 1
      ;;
  esac

  (
    cd "$dir"
    helm show values "$chart_ref" --version "$version" > values-default.yaml

    local -a template_args=(
      template "$releaseName" "$chart_ref"
      --version "$version"
    )
    if [[ -n "$namespace" && "$namespace" != "null" ]]; then
      template_args+=(-n "$namespace")
    fi
    if [[ "$includeCrds" == "true" ]]; then
      template_args+=(--include-crds)
    fi

    local n values_count
    values_count="$(yq -r '.valuesFiles | length' "$meta")"
    for ((n = 0; n < values_count; n++)); do
      template_args+=(-f "$(yq -r ".valuesFiles[$n]" "$meta")")
    done

    local api_count
    api_count="$(yq -r '.apiVersions // [] | length' "$meta")"
    for ((n = 0; n < api_count; n++)); do
      template_args+=(--api-versions "$(yq -r ".apiVersions[$n]" "$meta")")
    done

    local set_count
    set_count="$(yq -r '.setFiles // [] | length' "$meta")"
    for ((n = 0; n < set_count; n++)); do
      local key file
      key="$(yq -r ".setFiles[$n].key" "$meta")"
      file="$(yq -r ".setFiles[$n].file" "$meta")"
      template_args+=(--set-file "${key}=${file}")
    done

    helm "${template_args[@]}" > install.yaml
  )

  echo "    wrote $app/values-default.yaml and $app/install.yaml"
}

targets=()
if [[ "${1:-}" == "--all" ]]; then
  targets=("${HELM_APPS[@]}")
elif [[ $# -eq 0 ]]; then
  echo "usage: $0 <app-dir> [<app-dir> ...] | --all" >&2
  exit 1
else
  for arg in "$@"; do
    # Accept "immich" or "immich/" or absolute paths under ROOT
    arg="${arg#./}"
    arg="${arg%/}"
    targets+=("$(basename "$arg")")
  done
fi

for app in "${targets[@]}"; do
  render_app "$app"
done
