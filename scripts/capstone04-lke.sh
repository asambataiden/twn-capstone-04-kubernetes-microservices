#!/usr/bin/env bash
# Capstone 04 — LKE cluster lifecycle. No application deployment in this script.
set -Eeuo pipefail

CLUSTER_LABEL="${CLUSTER_LABEL:-twn-capstone04-lke}"
REGION="${REGION:-eu-central}"
K8S_VERSION="${K8S_VERSION:-1.35}"
NODE_TYPE="${NODE_TYPE:-g6-standard-2}"
NODE_COUNT=3
KUBECONFIG_FILE="${HOME}/.kube/twn-capstone04-lke.yaml"

die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
require() { command -v "$1" >/dev/null 2>&1 || die "Missing dependency: $1"; }
preflight() {
  require linode-cli
  require jq
  require kubectl
  require base64
  linode-cli lke versions-list --json | jq -e --arg v "$K8S_VERSION" 'any(.[]; .id == $v)' >/dev/null || die "LKE version $K8S_VERSION unavailable"
  linode-cli linodes types --json | jq -e --arg t "$NODE_TYPE" 'any(.[]; .id == $t)' >/dev/null || die "Node plan $NODE_TYPE unavailable"
  linode-cli lke clusters-list --json >/dev/null || die "Linode account access failed"
  printf 'Preflight OK: %s in %s, Kubernetes %s, %s x %s\n' "$CLUSTER_LABEL" "$REGION" "$K8S_VERSION" "$NODE_COUNT" "$NODE_TYPE"
}
cluster_id() {
  linode-cli lke clusters-list --json | jq -r --arg label "$CLUSTER_LABEL" '[.[] | select(.label == $label) | .id] | if length == 1 then .[0] else empty end'
}
create() {
  preflight
  local existing hourly cost response
  existing="$(cluster_id)"
  [[ -z "$existing" ]] || die "Cluster already exists (ID $existing); refusing to duplicate"
  hourly="$(linode-cli linodes types --json | jq -r --arg t "$NODE_TYPE" '.[] | select(.id == $t) | ([.region_prices[]? | select(.id == "eu-central") | .hourly][0] // .price.hourly)')"
  cost="$(awk -v p="$hourly" -v n="$NODE_COUNT" 'BEGIN {printf "%.3f", p*n}')"
  printf 'Will CREATE 3 billable workers; indicative worker cost USD %s/hour, excluding load balancers/storage/other fees.\n' "$cost"
  printf 'Type CREATE-%s to proceed: ' "$CLUSTER_LABEL"
  read -r response
  [[ "$response" == "CREATE-$CLUSTER_LABEL" ]] || die "Cancelled"
  linode-cli lke cluster-create --label "$CLUSTER_LABEL" --region "$REGION" \
    --k8s_version "$K8S_VERSION" --node_pools.type "$NODE_TYPE" --node_pools.count "$NODE_COUNT" --json
  printf 'Cluster creation requested. When ready, run: bash scripts/capstone04-lke.sh kubeconfig\n'
}
get_kubeconfig() {
  require linode-cli; require jq; require kubectl
  local id payload temporary
  id="$(cluster_id)"
  [[ -n "$id" ]] || die "Exactly one matching cluster is required"
  mkdir -p "${HOME}/.kube"
  chmod 700 "${HOME}/.kube"
  [[ ! -e "$KUBECONFIG_FILE" ]] || die "Kubeconfig already exists; refusing to overwrite: $KUBECONFIG_FILE"
  # A new LKE cluster can return HTTP 503 until credentials are provisioned.
  # Do not echo the API response: kubeconfig contains sensitive credentials.
  if ! payload="$(linode-cli lke kubeconfig-view "$id" --json 2>/dev/null)"; then
    die "Kubeconfig not available yet (LKE can take several minutes). Retry this subcommand; do not recreate the cluster"
  fi
  temporary="$(mktemp "${HOME}/.kube/.cap04-kubeconfig.XXXXXX")"
  chmod 600 "$temporary"
  trap 'rm -f "$temporary"' EXIT
  # jq decodes base64 portably on macOS and Linux; never print the credentials.
  if ! printf '%s' "$payload" | jq -er '.[0].kubeconfig | @base64d' > "$temporary"; then
    die "Invalid or unavailable kubeconfig response"
  fi
  KUBECONFIG="$temporary" kubectl config view -o json | jq -e '.clusters | length > 0' >/dev/null || die "Invalid kubeconfig"
  mv "$temporary" "$KUBECONFIG_FILE"
  trap - EXIT
  printf 'Kubeconfig saved locally (DO NOT COMMIT): %s\n' "$KUBECONFIG_FILE"
  printf 'Next: bash scripts/capstone04-lke.sh verify\n'
}
verify() {
  require kubectl
  [[ -f "$KUBECONFIG_FILE" ]] || die "Missing kubeconfig: $KUBECONFIG_FILE"
  kubectl --kubeconfig "$KUBECONFIG_FILE" cluster-info
  kubectl --kubeconfig "$KUBECONFIG_FILE" get nodes -o wide
  local ready
  ready="$(kubectl --kubeconfig "$KUBECONFIG_FILE" get nodes -o json | jq '[.items[] | select(any(.status.conditions[]; .type == "Ready" and .status == "True"))] | length')"
  [[ "$ready" -eq "$NODE_COUNT" ]] || die "Expected $NODE_COUNT Ready workers; observed $ready"
  printf 'All %s LKE workers Ready.\n' "$NODE_COUNT"
}
destroy() {
  require linode-cli; require jq
  local id response
  id="$(cluster_id)"
  [[ -n "$id" ]] || die "Exactly one cluster named $CLUSTER_LABEL required; nothing deleted"
  printf 'WARNING: permanently delete LKE cluster %s (ID %s) and its workers.\n' "$CLUSTER_LABEL" "$id"
  printf 'Type DELETE-%s to proceed: ' "$id"
  read -r response
  [[ "$response" == "DELETE-$id" ]] || die "Cancelled"
  linode-cli lke cluster-delete "$id"
  printf 'Deletion requested. Check for orphan NodeBalancers and Block Storage volumes in Linode Cloud Manager; these may still be billable.\n'
}
case "${1:-}" in
  preflight) preflight ;;
  create) create ;;
  kubeconfig) get_kubeconfig ;;
  verify) verify ;;
  destroy) destroy ;;
  *) printf 'Usage: bash %s {preflight|create|kubeconfig|verify|destroy}\n' "$0"; exit 2 ;;
esac
