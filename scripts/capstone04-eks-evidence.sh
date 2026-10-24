#!/usr/bin/env bash
set -Eeuo pipefail

# CAP04-003 — Read-only evidence for the existing TWN EKS Online Boutique deployment.
# This deliberately does NOT use the CAP04 k3d deployment script or mutate any resources.
readonly AWS_REGION="eu-north-1"
readonly EKS_NAME="floral-mongoose-1792497995"
readonly CTX="aws-admin-asamba.tamajong.aiden@outlook.com@floral-mongoose-1792497995.eu-north-1.eksctl.io"
readonly NS="online-shop"

die() { printf '[cap04-evidence] ERROR: %s\n' "$*" >&2; exit 1; }
log() { printf '\n[cap04-evidence] %s\n' "$*"; }
for tool in aws kubectl; do
  command -v "$tool" >/dev/null 2>&1 || die "Missing executable: $tool"
done

# AWS CLI command reads account/cluster metadata only. Reject wrong/retired cluster.
cluster_status="$(aws eks describe-cluster --name "$EKS_NAME" --region "$AWS_REGION" --query 'cluster.status' --output text)" ||
  die "Could not describe intended EKS cluster"
[[ "$cluster_status" == "ACTIVE" ]] || die "EKS cluster is not ACTIVE: $cluster_status"

# Cross-check that the kubeconfig context points to the exact live EKS endpoint.
expected_endpoint="$(aws eks describe-cluster --name "$EKS_NAME" --region "$AWS_REGION" --query 'cluster.endpoint' --output text)" ||
  die "Could not obtain EKS API endpoint"
actual_endpoint="$(kubectl config view --raw -o jsonpath="{.contexts[?(@.name=='$CTX')].context.cluster}")" ||
  die "Could not resolve intended kubectl context"
[[ -n "$actual_endpoint" ]] || die "Kubeconfig context missing: $CTX"
context_server="$(kubectl config view --raw -o jsonpath="{.clusters[?(@.name=='$actual_endpoint')].cluster.server}")" ||
  die "Could not resolve the context API server"
[[ "$expected_endpoint" == "$context_server" ]] ||
  die "Context server does not match the live intended AWS EKS cluster"

kubectl --context "$CTX" get namespace "$NS" >/dev/null ||
  die "Existing namespace not accessible: $NS"

log "TARGET: $EKS_NAME ($AWS_REGION), namespace $NS; all following operations read-only"
log "Cluster nodes and architecture"
kubectl --context "$CTX" get nodes -o 'custom-columns=NAME:.metadata.name,READY:.status.conditions[-1].type,ARCH:.status.nodeInfo.architecture'
log "Application image inventory"
kubectl --context "$CTX" -n "$NS" get deployments \
  -o 'custom-columns=NAME:.metadata.name,AVAILABLE:.status.availableReplicas,IMAGE:.spec.template.spec.containers[*].image'
log "Pod health and restarts"
kubectl --context "$CTX" -n "$NS" get pods
log "Frontend services (note public exposure if LoadBalancer is present)"
kubectl --context "$CTX" -n "$NS" get service frontend frontend-external
log "Finished: inventory only; no workloads changed"
