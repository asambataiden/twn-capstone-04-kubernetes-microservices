#!/usr/bin/env bash
set -Eeuo pipefail

# CAP04-002: dedicated, local k3d laboratory lifecycle.
# Always run with: bash scripts/capstone04-cluster.sh <command>
# Intentionally never uses whichever kubectl context happens to be current.

readonly CLUSTER_NAME="twn-capstone04"
readonly CONTEXT="k3d-${CLUSTER_NAME}"
readonly NAMESPACE="online-boutique"

log() { printf '[cap04] %s\n' "$*"; }
die() { printf '[cap04] ERROR: %s\n' "$*" >&2; exit 1; }
require() { command -v "$1" >/dev/null 2>&1 || die "Missing command: $1"; }

usage() {
  cat <<'USAGE'
Usage: bash scripts/capstone04-cluster.sh <command>

  preflight  Check required tools, Docker and current context (read-only)
  create     Create dedicated local k3d cluster if absent; then verify it
  verify     Check the dedicated cluster and its system Pods (read-only)
  namespace  Create online-boutique namespace if absent; then verify it
  status     Show cluster nodes and namespace workloads (read-only)
  destroy    Explicitly delete only the dedicated lab cluster (confirmation required)

No application deployment is performed by this script.
USAGE
}

cluster_exists() {
  # k3d cluster get succeeds only if this specific cluster exists.
  k3d cluster get "$CLUSTER_NAME" >/dev/null 2>&1
}

require_context() {
  kubectl config get-contexts -o name | grep -Fxq -- "$CONTEXT" \
    || die "Expected kubeconfig context '$CONTEXT' does not exist"
}

kubecap() {
  require kubectl
  require_context
  kubectl --context "$CONTEXT" "$@"
}

preflight() {
  require docker
  require k3d
  require kubectl
  docker info >/dev/null || die "Docker engine unavailable"
  log "Docker: $(docker --version)"
  log "k3d: $(k3d version | head -n 1)"
  log "kubectl: $(kubectl version --client | head -n 1)"
  log "Current context (informational ONLY): $(kubectl config current-context 2>/dev/null || printf '(none)')"
  k3d cluster list
}

verify() {
  require k3d
  cluster_exists || die "Dedicated cluster '$CLUSTER_NAME' does not exist; run create"
  kubecap cluster-info
  kubecap get nodes -o wide
  kubecap get pods -n kube-system
}

create() {
  preflight
  if cluster_exists; then
    log "Cluster '$CLUSTER_NAME' already exists; no modification"
  else
    log "Creating dedicated local cluster '$CLUSTER_NAME'"
    k3d cluster create "$CLUSTER_NAME" --servers 1 --agents 0 --wait
  fi
  verify
  log "Use explicit context '$CONTEXT' for all subsequent commands"
}

namespace() {
  require k3d
  cluster_exists || die "Cluster missing; run create"
  kubecap get nodes >/dev/null || die "Target cluster is not reachable"
  if kubecap get namespace "$NAMESPACE" >/dev/null 2>&1; then
    log "Namespace '$NAMESPACE' already exists; no modification"
  else
    kubecap create namespace "$NAMESPACE"
  fi
  kubecap get namespace "$NAMESPACE" -o wide
}

status() {
  require k3d
  cluster_exists || die "Cluster missing; run create"
  kubecap get nodes
  if kubecap get namespace "$NAMESPACE" >/dev/null 2>&1; then
    kubecap -n "$NAMESPACE" get deployments,pods,services
  else
    log "Namespace '$NAMESPACE' has not been created"
  fi
}

destroy() {
  require k3d
  if ! cluster_exists; then
    log "Cluster '$CLUSTER_NAME' absent; nothing to delete"
    return
  fi
  [[ -t 0 ]] || die "Destruction requires interactive confirmation"
  printf 'Type DELETE %s to delete only this lab cluster: ' "$CLUSTER_NAME"
  local response
  IFS= read -r response
  [[ "$response" == "DELETE $CLUSTER_NAME" ]] || die "Confirmation did not match; no deletion"
  k3d cluster delete "$CLUSTER_NAME"
  log "Dedicated cluster removed; existing banking and EKS clusters were not targeted"
}

case "${1:-}" in
  preflight) preflight ;;
  create) create ;;
  verify) verify ;;
  namespace) namespace ;;
  status) status ;;
  destroy) destroy ;;
  -h|--help|help) usage ;;
  *) usage >&2; exit 2 ;;
esac
